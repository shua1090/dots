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

vim.keymap.set("n", "<leader>tt", "<Cmd>BufferPick<CR>", { desc = "Pick buffer", silent = true })
vim.keymap.set("n", "<leader>tq", "<Cmd>BufferClose<CR>", { desc = "Close buffer", silent = true })
vim.keymap.set("n", "<leader>tn", "<Cmd>BufferNext<CR>", { desc = "Next buffer", silent = true })
vim.keymap.set("n", "<leader>tN", "<Cmd>BufferPrevious<CR>", { desc = "Previous buffer", silent = true })

local function cycle_buffer(forward)
  vim.cmd(forward and "BufferNext" or "BufferPrevious")
end

vim.keymap.set({ "n", "i", "t" }, "<C-Tab>", function()
  cycle_buffer(true)
end, { desc = "Next buffer", silent = true })
vim.keymap.set({ "n", "i", "t" }, "<C-S-Tab>", function()
  cycle_buffer(false)
end, { desc = "Previous buffer", silent = true })
vim.keymap.set({ "n", "i", "t" }, "<C-ISO_Left_Tab>", function()
  cycle_buffer(false)
end, { desc = "Previous buffer", silent = true })
