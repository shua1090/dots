return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local actions = require("diffview.actions")
    local lib = require("diffview.lib")

    local function refresh_files()
      pcall(actions.refresh_files)
    end

    local function write_buffer(bufnr)
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd("silent! update")
      end)
    end

    local function stage_or_unstage_hunk()
      local view = lib.get_current_view()
      local entry = view and view.cur_entry or nil
      local layout = entry and entry.layout or nil

      if not entry or not layout or not layout.a or not layout.b then
        return
      end

      local index_winid
      local index_bufnr
      if entry.kind == "working" then
        index_winid = layout.a.id
        index_bufnr = layout.a.file.bufnr
      elseif entry.kind == "staged" then
        index_winid = layout.b.id
        index_bufnr = layout.b.file.bufnr
      else
        vim.notify(("No hunk stage action for entry kind: %s"):format(entry.kind), vim.log.levels.INFO)
        return
      end

      if not index_winid or not index_bufnr or not vim.api.nvim_win_is_valid(index_winid) then
        return
      end

      local current_winid = vim.api.nvim_get_current_win()
      local mode = vim.api.nvim_get_mode().mode
      local visual = mode:match("^[vV\22]") ~= nil
      local use_diffget = current_winid == index_winid

      local before_tick = vim.api.nvim_buf_get_changedtick(index_bufnr)
      local ok, err = pcall(function()
        if use_diffget then
          if visual then
            vim.cmd("'<,'>diffget")
          else
            vim.cmd("normal! do")
          end
        else
          if visual then
            vim.cmd("'<,'>diffput")
          else
            vim.cmd("normal! dp")
          end
        end
      end)

      if not ok then
        vim.notify(("Diffview hunk operation failed: %s"):format(err), vim.log.levels.ERROR)
        return
      end

      local after_tick = vim.api.nvim_buf_get_changedtick(index_bufnr)
      if after_tick == before_tick then
        vim.notify("No hunk found at cursor/range to apply.", vim.log.levels.INFO)
        return
      end

      write_buffer(index_bufnr)
      refresh_files()
    end

    require("diffview").setup({
      enhanced_diff_hl = true,
      keymaps = {
        view = {
          { { "n", "x" }, "<leader>gs", stage_or_unstage_hunk, { desc = "Stage/unstage hunk at cursor/selection (Diffview)" } },
          { { "n", "x" }, "<leader>gS", stage_or_unstage_hunk, { desc = "Stage/unstage hunk at cursor/selection (Diffview)" } },
          { "n", "gf", actions.focus_files, { desc = "Focus files panel (stay in Diffview)" } },
        },
        file_panel = {
          { "n", "<leader>gs", actions.toggle_stage_entry, { desc = "Stage/unstage selected entry" } },
          { "n", "<leader>gS", actions.toggle_stage_entry, { desc = "Stage/unstage selected entry" } },
          { "n", "gf", actions.select_entry, { desc = "Open diff for selected entry (in-place)" } },
        },
      },
    })
  end,
}
