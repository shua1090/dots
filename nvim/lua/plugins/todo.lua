return {
  "folke/todo-comments.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    signs = true,
  },
  keys = {
    {
      "]t",
      function()
        require("todo-comments").jump_next()
      end,
      desc = "Next todo comment",
    },
    {
      "[t",
      function()
        require("todo-comments").jump_prev()
      end,
      desc = "Previous todo comment",
    },
    {
      "<leader>ft",
      function()
        require("todo-comments.fzf").todo()
      end,
      desc = "Find todo comments",
    },
    {
      "<leader>fT",
      function()
        require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } })
      end,
      desc = "Find todo/fix comments",
    },
    {
      "<leader>lT",
      "<cmd>Trouble todo toggle<cr>",
      desc = "Todo comments (Trouble)",
    },
  },
}
