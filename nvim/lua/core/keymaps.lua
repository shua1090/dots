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
