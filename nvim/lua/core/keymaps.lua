-- ~/.config/nvim/lua/core/keymaps.lua

local map = vim.keymap.set

-- jj to escape
map("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- -- Keep things centered
-- map("n", "n", "nzzzv")
-- map("n", "N", "Nzzzv")

-- -- Leader sanity check
-- map("n", "<leader>?", function()
--   print("Leader key works!")
-- end, { desc = "Test leader key" })
--
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

