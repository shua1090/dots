return {
  "AckslD/nvim-neoclip.lua",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("neoclip").setup({
      history = 1000,
      enable_persistent_history = false,
      preview = true,
      default_register = { '"', "+", "*" },
      initial_mode = "normal",
    })
    pcall(require("telescope").load_extension, "neoclip")
  end,
  keys = {
    {
      "<leader>v",
      function()
        require("telescope").extensions.neoclip.default()
      end,
      desc = "Clipboard history",
    },
  },
}
