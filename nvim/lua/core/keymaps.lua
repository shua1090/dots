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

local function is_floating_window(winid)
  local cfg = vim.api.nvim_win_get_config(winid)
  return cfg.relative ~= ""
end

local function move_to_non_floating_window(direction)
  local start_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_tabpage_list_wins(0)

  if #wins <= 1 then
    return
  end

  -- If we're currently inside a float, jump to any regular window first.
  if is_floating_window(start_win) then
    for _, winid in ipairs(wins) do
      if vim.api.nvim_win_is_valid(winid) and not is_floating_window(winid) then
        vim.api.nvim_set_current_win(winid)
        start_win = winid
        break
      end
    end
  end

  for _ = 1, #wins do
    vim.cmd("wincmd " .. direction)
    if not is_floating_window(vim.api.nvim_get_current_win()) then
      return
    end
  end

  -- Restore if we only cycled through floats.
  if vim.api.nvim_win_is_valid(start_win) then
    vim.api.nvim_set_current_win(start_win)
  end
end

vim.keymap.set("n", "<C-h>", function()
  move_to_non_floating_window("h")
end, { desc = "Move to left window" })

vim.keymap.set("n", "<C-j>", function()
  move_to_non_floating_window("j")
end, { desc = "Move to lower window" })

vim.keymap.set("n", "<C-k>", function()
  move_to_non_floating_window("k")
end, { desc = "Move to upper window" })

vim.keymap.set("n", "<C-l>", function()
  move_to_non_floating_window("l")
end, { desc = "Move to right window" })

pcall(vim.keymap.del, "n", "gw")
pcall(vim.keymap.del, "x", "gw")
pcall(vim.keymap.del, "o", "gw")

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

-- remap gw to Hop (Helix-style)
vim.keymap.set({ "n", "x", "o" }, "gw", function()
  require("hop").hint_words()
end, { desc = "Hop to visible word" })

-- local function capture_view(win)
--   return vim.api.nvim_win_call(win, function()
--     return vim.fn.winsaveview()
--   end)
-- end
--
-- local function restore_view(win, view)
--   vim.api.nvim_win_call(win, function()
--     vim.fn.winrestview(view)
--   end)
-- end
--
-- local function move_window(direction)
--   local current_win = vim.api.nvim_get_current_win()
--   local current_nr = vim.fn.winnr()
--   local target_nr = vim.fn.winnr(direction)
--
--   if target_nr == 0 or target_nr == current_nr then
--     return
--   end
--
--   local target_win = vim.fn.win_getid(target_nr)
--   if not target_win or target_win == 0 then
--     return
--   end
--
--   local current_buf = vim.api.nvim_win_get_buf(current_win)
--   local target_buf = vim.api.nvim_win_get_buf(target_win)
--   local current_view = capture_view(current_win)
--   local target_view = capture_view(target_win)
--
--   vim.api.nvim_win_set_buf(current_win, target_buf)
--   vim.api.nvim_win_set_buf(target_win, current_buf)
--
--   restore_view(current_win, target_view)
--   restore_view(target_win, current_view)
--   vim.api.nvim_set_current_win(target_win)
-- end
--
-- vim.keymap.set("n", "<C-w>h", function()
--   move_window("h")
-- end, { desc = "Move window one step left" })
-- vim.keymap.set("n", "<C-w>j", function()
--   move_window("j")
-- end, { desc = "Move window one step down" })
-- vim.keymap.set("n", "<C-w>k", function()
--   move_window("k")
-- end, { desc = "Move window one step up" })
-- vim.keymap.set("n", "<C-w>l", function()
--   move_window("l")
-- end, { desc = "Move window one step right" })
