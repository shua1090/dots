return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {
      "<leader>lq",
      "<cmd>Trouble diagnostics toggle focus=false<cr>",
      desc = "Diagnostics (Trouble)",
    },
    {
      "<leader>lQ",
      "<cmd>Trouble diagnostics toggle focus=false filter.buf=0<cr>",
      desc = "Buffer diagnostics (Trouble)",
    },
    {
      "<leader>ll",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP list (Trouble)",
    },
    {
      "<leader>ls",
      "<cmd>Trouble symbols toggle focus=false pinned=true win.relative=win win.position=right<cr>",
      desc = "Document symbols (Trouble)",
    },
    {
      "<leader>lx",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Location list (Trouble)",
    },
    {
      "<leader>lX",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Quickfix list (Trouble)",
    },
    {
      "<leader>o",
      "<cmd>Trouble symbols toggle focus=false pinned=true win.relative=win win.position=right<cr>",
      desc = "Outline (Trouble)",
    },
  },
  opts = {
    focus = false,
    follow = true,
    auto_preview = true,
    modes = {
      diagnostics_buffer = {
        mode = "diagnostics",
        filter = { buf = 0 },
      },
    },
  },
}
