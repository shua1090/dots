return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 950,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      integrations = {
        treesitter = true,
        native_lsp = {
          enabled = true,
        },
      },
    })
  end,
}
