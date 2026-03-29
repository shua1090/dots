return {
  "rose-pine/neovim",
  name = "rose-pine",
  lazy = false,
  priority = 950,
  config = function()
    require("rose-pine").setup({
      variant = "moon",
      dark_variant = "moon",
    })
  end,
}
