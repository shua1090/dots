require("toggleterm").setup({
  size = 20,
  open_mapping = [[<c-\>]], -- internal fallback
  shade_terminals = true,
  shading_factor = 2,
  direction = "float",
  float_opts = {
    border = "rounded",
  },
  start_in_insert = true,
  insert_mappings = true,
  persist_size = true,
  close_on_exit = false,
})

vim.keymap.set("n", "<leader><CR>", function()
  require("toggleterm").toggle()
end, { desc = "Toggle terminal" })

vim.keymap.set("t", "<leader><CR>", [[<C-\><C-n><cmd>lua require("toggleterm").toggle()<CR>]],
  { desc = "Toggle terminal" }
)

