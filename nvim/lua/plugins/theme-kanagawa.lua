return {
  "rebelot/kanagawa.nvim",
  lazy = false,
  priority = 950,
  config = function()
    require("kanagawa").setup({
      compile = false,
      transparent = false,
      theme = "wave",
    })
  end,
}
