return {
  "willothy/nvim-cokeline",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "stevearc/resession.nvim",
  },
  config = function()
    require("cokeline").setup({
      pick = {
        use_filename = false,
        letters = "asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERTYQP",
      },
    })

    vim.keymap.set(
      "n",
      "<leader>t",
      "<Plug>(cokeline-pick-focus)",
      { desc = "Pick buffer from bufferline", silent = true }
    )
  end,
}

