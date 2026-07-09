return {
  "AckslD/nvim-neoclip.lua",
  event = "VeryLazy",
  config = function()
    require("neoclip").setup({
      history = 1000,
      enable_persistent_history = false,
      preview = true,
      default_register = { '"', "+", "*" },
      initial_mode = "normal",
    })
  end,
  keys = {
    {
      "<leader>v",
      function()
        require("neoclip.fzf")()
      end,
      desc = "Clipboard history",
    },
  },
}
