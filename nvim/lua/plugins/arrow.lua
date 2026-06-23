return {
  "otavioschwanck/arrow.nvim",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    show_icons = true,
    leader_key = ";",
  },
  config = function(_, opts)
    require("arrow").setup(opts)

    local persist = require("arrow.persist")
    vim.keymap.set("n", "]m", persist.next, { silent = true, desc = "Arrow: Next file" })
    vim.keymap.set("n", "[m", persist.previous, { silent = true, desc = "Arrow: Previous file" })
  end,
}
