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

vim.keymap.set("n", "<leader>gd", "<Cmd>DiffviewOpen<CR>", { desc = "Diffview: staged + unstaged", silent = true })
vim.keymap.set("n", "<leader>gD", function()
  vim.ui.input({ prompt = "Diff current branch against: " }, function(branch)
    if branch and branch ~= "" then
      vim.cmd("DiffviewOpen " .. branch .. "...HEAD")
    end
  end)
end, { desc = "Diffview: diff against branch", silent = true })
vim.keymap.set("n", "<leader>gf", "<Cmd>DiffviewFileHistory %<CR>", { desc = "Diffview: file history", silent = true })
vim.keymap.set("n", "<leader>gF", "<Cmd>DiffviewFileHistory<CR>", { desc = "Diffview: repo history", silent = true })
vim.keymap.set("n", "<leader>gc", "<Cmd>DiffviewClose<CR>", { desc = "Diffview: close", silent = true })
