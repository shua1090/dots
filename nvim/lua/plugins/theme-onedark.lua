return {
  "navarasu/onedark.nvim",
  lazy = false,
  priority = 950,
  config = function()
    require("onedark").setup({
      style = "dark",
    })
  end,
}
