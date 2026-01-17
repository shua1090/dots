return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        hover = {
          enabled = true,
          opts = {
            position = { row = 1, col = -2, anchor = "NE" },
            size = { width = 80 },
            border = "rounded",
          },
        },
        signature = { enabled = false },
        progress = { enabled = false },
      },
      presets = { lsp_doc_border = true },
    },
  },
  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    opts = {
      handlers = {
        diagnostic = true,
        gitsigns = false,
        search = false,
      },
      show = true,
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
