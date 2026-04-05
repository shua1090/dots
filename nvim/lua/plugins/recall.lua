return {
  "fnune/recall.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local recall = require("recall")
    recall.setup({})

    vim.keymap.set("n", "<leader>mm", recall.toggle, { noremap = true, silent = true, desc = "Recall: Toggle mark" })
    vim.keymap.set("n", "<leader>mn", recall.goto_next, { noremap = true, silent = true, desc = "Recall: Next mark" })
    vim.keymap.set("n", "<leader>mp", recall.goto_prev, { noremap = true, silent = true, desc = "Recall: Previous mark" })
    vim.keymap.set("n", "<leader>mc", recall.clear, { noremap = true, silent = true, desc = "Recall: Clear marks" })
    vim.keymap.set("n", "<leader>ml", ":Telescope recall<CR>", {
      noremap = true,
      silent = true,
      desc = "Recall: List marks (Telescope)",
    })
  end,
}
