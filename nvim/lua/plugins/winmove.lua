vim.keymap.set("n", "<leader>wm", function()
  require("winmove").start_mode("move")
end)

vim.keymap.set("n", "<leader>ws", function()
  require("winmove").start_mode("swap")
end)

vim.keymap.set("n", "<leader>wr", function()
  require("winmove").start_mode("resize")
end)

return {
  {
    'MisanthropicBit/winmove.nvim',
      config = function()
        require("nvim-web-devicons").setup({ default = true })
      end,
  },
}

