require("aerial").setup({
  backends = { "lsp", "treesitter", "markdown" },
  layout = {
    min_width = 24,
    max_width = 48,
  },
  filter_kind = false,
  show_guides = true,
})

vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle<cr>", { desc = "Outline (aerial)" })
