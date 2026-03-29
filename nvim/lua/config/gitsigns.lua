require("gitsigns").setup({
  signs = {
    add          = { text = "│" },
    change       = { text = "│" },
    delete       = { text = "_" },
    topdelete    = { text = "‾" },
    changedelete = { text = "~" },
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map("n", "<leader>gs", gs.stage_hunk, "Git stage hunk")
    map("v", "<leader>gs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Git stage selected hunk")
    map("n", "<leader>gS", gs.undo_stage_hunk, "Git unstage hunk")
  end,
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 500,
  },
})

-- vim.keymap.set("n", "<leader>gb", function()
--   require("gitsigns").toggle_current_line_blame()
-- end, { desc = "Toggle git blame" })
