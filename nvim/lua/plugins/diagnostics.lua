return {
  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    opts = {
      show = true,
      show_in_active_only = true,
      throttle_ms = 80,
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true,
        search = false,
      },
      handle = {
        text = " ",
        blend = 0,
        highlight = "CursorColumn",
      },
      marks = {
        Cursor = { text = " ", highlight = "CursorLine", priority = 0 },
        Search = { text = { "-", "=" }, highlight = "Search", priority = 1 },
        Error = { text = { "-", "=" }, highlight = "DiagnosticError", priority = 2 },
        Warn = { text = { "-", "=" }, highlight = "DiagnosticWarn", priority = 3 },
        Info = { text = { "-", "=" }, highlight = "DiagnosticInfo", priority = 4 },
        Hint = { text = { "-", "=" }, highlight = "DiagnosticHint", priority = 5 },
        GitAdd = { text = "|", highlight = "GitSignsAdd", priority = 6 },
        GitChange = { text = "|", highlight = "GitSignsChange", priority = 6 },
        GitDelete = { text = "_", highlight = "GitSignsDelete", priority = 6 },
      },
      excluded_filetypes = {
        "aerial",
        "alpha",
        "lazy",
        "mason",
        "neo-tree",
        "noice",
        "TelescopePrompt",
      },
    },
  },
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    event = "LspAttach",
    config = function()
      require("lsp_lines").setup()
      vim.diagnostic.config({
        virtual_text = false, -- avoid duplicate text with lsp_lines
        virtual_lines = true,
      })
    end,
  },
}
