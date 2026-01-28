return {
  "kosayoda/nvim-lightbulb",
  config = function()
    require("nvim-lightbulb").setup({
      sign = { enabled = true },
      virtual_text = { enabled = false },
      float = { enabled = false },
      number = { enabled = false },
      line = { enabled = false },
      autocmd = { enabled = true },
    })
  end,
}
