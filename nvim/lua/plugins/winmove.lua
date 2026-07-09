return {
  "MisanthropicBit/winmove.nvim",
  keys = {
    {
      "<leader>wm",
      function()
        require("winmove").start_mode("move")
      end,
      desc = "Move window",
    },
    {
      "<leader>ws",
      function()
        require("winmove").start_mode("swap")
      end,
      desc = "Swap window",
    },
    {
      "<leader>wr",
      function()
        require("winmove").start_mode("resize")
      end,
      desc = "Resize window",
    },
  },
}
