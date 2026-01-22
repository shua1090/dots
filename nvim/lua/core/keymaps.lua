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

local function capture_view(win)
  return vim.api.nvim_win_call(win, function()
    return vim.fn.winsaveview()
  end)
end

local function restore_view(win, view)
  vim.api.nvim_win_call(win, function()
    vim.fn.winrestview(view)
  end)
end

local function move_window(direction)
  local current_win = vim.api.nvim_get_current_win()
  local current_nr = vim.fn.winnr()
  local target_nr = vim.fn.winnr(direction)

  if target_nr == 0 or target_nr == current_nr then
    return
  end

  local target_win = vim.fn.win_getid(target_nr)
  if not target_win or target_win == 0 then
    return
  end

  local current_buf = vim.api.nvim_win_get_buf(current_win)
  local target_buf = vim.api.nvim_win_get_buf(target_win)
  local current_view = capture_view(current_win)
  local target_view = capture_view(target_win)

  vim.api.nvim_win_set_buf(current_win, target_buf)
  vim.api.nvim_win_set_buf(target_win, current_buf)

  restore_view(current_win, target_view)
  restore_view(target_win, current_view)
  vim.api.nvim_set_current_win(target_win)
end

vim.keymap.set("n", "<C-w>h", function()
  move_window("h")
end, { desc = "Move window one step left" })
vim.keymap.set("n", "<C-w>j", function()
  move_window("j")
end, { desc = "Move window one step down" })
vim.keymap.set("n", "<C-w>k", function()
  move_window("k")
end, { desc = "Move window one step up" })
vim.keymap.set("n", "<C-w>l", function()
  move_window("l")
end, { desc = "Move window one step right" })
