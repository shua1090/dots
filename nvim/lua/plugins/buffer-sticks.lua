-- lua/plugins/buffer-sticks.lua
return {
  "ahkohd/buffer-sticks.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>j",
      function()
        require("buffer-sticks").jump()
      end,
      desc = "Jump to buffer",
    },
  },
  config = function()
    require("buffer-sticks").setup({
      -- close the UI as soon as a buffer is selected
      close_on_select = true,
      highlight_current = true,
    })
  end,
}

