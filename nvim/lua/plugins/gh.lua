return {
  "gh-tui-tools/gh-review.nvim",
  cmd = {
    "GHReview",
    "GHReviewFiles",
    "GHReviewStart",
    "GHReviewSubmit",
    "GHReviewDiscard",
    "GHReviewClose",
  },
  keys = {
    { "<leader>gh", "<cmd>GHReview<cr>", desc = "GitHub: Review PR" },
  },
  config = function()
    local group = vim.api.nvim_create_augroup("user_gh_review", { clear = true })

    local function cleanup_empty_placeholders()
      for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        local bufnr = info.bufnr
        if info.hidden == 1
            and info.name == ""
            and info.changed == 0
            and vim.api.nvim_buf_is_loaded(bufnr)
            and vim.bo[bufnr].buftype == ""
            and vim.bo[bufnr].filetype == ""
            and vim.api.nvim_buf_line_count(bufnr) == 1
            and vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] == "" then
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end
      end
    end

    local function arrange_windows()
      local state = require("gh_review.state")
      local save_winid = vim.fn.win_getid()
      local files = state.get_files_bufnr()
      local files_winid = files ~= -1 and vim.fn.bufwinid(files) or -1
      local left_winid = state.get_left_bufnr() ~= -1 and vim.fn.bufwinid(state.get_left_bufnr()) or -1
      local right_winid = state.get_right_bufnr() ~= -1 and vim.fn.bufwinid(state.get_right_bufnr()) or -1

      if files_winid ~= -1 then
        vim.fn.win_gotoid(files_winid)
        vim.cmd("wincmd H")
        vim.cmd("vertical resize 42")
        vim.wo.winfixheight = false
        vim.wo.winfixwidth = true
      end

      for _, bufnr in ipairs({ state.get_left_bufnr(), state.get_right_bufnr() }) do
        if bufnr ~= -1 and vim.fn.bufexists(bufnr) == 1 then
          vim.bo[bufnr].buflisted = false
        end
      end

      if left_winid ~= -1 and right_winid ~= -1 then
        vim.cmd("wincmd =")
        if files_winid ~= -1 and vim.api.nvim_win_is_valid(files_winid) then
          vim.fn.win_gotoid(files_winid)
          vim.cmd("vertical resize 42")
        end
      end

      cleanup_empty_placeholders()

      if vim.api.nvim_win_is_valid(save_winid) then
        vim.fn.win_gotoid(save_winid)
      end
    end

    local function open_file_under_cursor()
      local lnum = vim.fn.line(".")
      if lnum <= 3 then return end

      local files = require("gh_review.state").get_changed_files()
      local file = files[lnum - 3]
      if not file or not file.path then return end

      local state = require("gh_review.state")
      local diff = require("gh_review.diff")
      arrange_windows()

      local files_winid = vim.fn.bufwinid(state.get_files_bufnr())
      local right_winid = state.get_right_bufnr() ~= -1 and vim.fn.bufwinid(state.get_right_bufnr()) or -1
      if files_winid ~= -1 and right_winid == -1 then
        vim.fn.win_gotoid(files_winid)
        vim.cmd("wincmd l")
        if vim.fn.win_getid() == files_winid then
          vim.cmd("rightbelow vnew")
        end
        local target_bufnr = vim.api.nvim_get_current_buf()
        vim.bo[target_bufnr].bufhidden = "wipe"
        vim.bo[target_bufnr].buflisted = false
        state.set_right_bufnr(target_bufnr)
      end

      diff.open(file.path)
      vim.defer_fn(arrange_windows, 100)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "gh-review-files",
      callback = function(args)
        vim.bo[args.buf].buflisted = false
        vim.schedule(function()
          vim.keymap.set("n", "<CR>", open_file_under_cursor, { buffer = args.buf, silent = true, desc = "Open diff" })
          arrange_windows()
        end)
      end,
    })

    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufAdd" }, {
      group = group,
      pattern = "gh-review://*",
      callback = function(args)
        vim.bo[args.buf].buflisted = false
        vim.schedule(arrange_windows)
      end,
    })
  end,
}
