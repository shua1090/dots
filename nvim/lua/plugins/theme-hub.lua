return {
  "erl-koenig/theme-hub.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("theme-hub").setup({
      -- default options
    })
  end,
}
