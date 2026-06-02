local toggleterm = require("toggleterm")
local Terminal = require("toggleterm.terminal").Terminal

toggleterm.setup({
  size = function(term)
    if term.direction == "horizontal" then
      return math.floor(vim.o.lines * 0.3)
    end
    if term.direction == "vertical" then
      return math.floor(vim.o.columns * 0.4)
    end
    return 20
  end,
  open_mapping = [[<c-\>]],
  shade_terminals = true,
  shading_factor = 2,
  direction = "horizontal",
  float_opts = {
    border = "rounded",
  },
  start_in_insert = true,
  insert_mappings = true,
  terminal_mappings = true,
  persist_size = true,
  persist_mode = true,
  close_on_exit = false,
})

local float_term = Terminal:new({
  count = 99,
  hidden = true,
  direction = "float",
  close_on_exit = false,
  float_opts = {
    border = "rounded",
  },
})

local ai_terms = {
  codex = Terminal:new({
    count = 90,
    cmd = "codex",
    hidden = true,
    direction = "vertical",
    close_on_exit = false,
  }),
  pi = Terminal:new({
    count = 91,
    cmd = "pi",
    hidden = true,
    direction = "vertical",
    close_on_exit = false,
  }),
}

local ai_origin_win

local function ai_panel_width()
  return math.max(50, math.floor(vim.o.columns * 0.42))
end

local function is_ai_terminal_window(win)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return false
  end

  local bufnr = vim.api.nvim_win_get_buf(win)
  for _, term in pairs(ai_terms) do
    if term.bufnr == bufnr then
      return true
    end
  end

  return false
end

local function remember_origin_window()
  local win = vim.api.nvim_get_current_win()
  if not is_ai_terminal_window(win) then
    ai_origin_win = win
  end
end

local function focus_origin_window()
  if ai_origin_win and vim.api.nvim_win_is_valid(ai_origin_win) then
    vim.api.nvim_set_current_win(ai_origin_win)
  end
end

local function toggle_bottom()
  vim.cmd("1ToggleTerm direction=horizontal")
  vim.schedule(function()
    if vim.bo.buftype == "terminal" then
      vim.cmd("startinsert")
    end
  end)
end

local function toggle_float()
  float_term:toggle()
end

local function toggle_ai(name)
  local term = ai_terms[name]
  if not term then
    vim.notify("Unknown AI terminal: " .. name, vim.log.levels.ERROR)
    return
  end

  if term:is_open() then
    term:close()
    focus_origin_window()
    return
  end

  remember_origin_window()

  for other_name, other_term in pairs(ai_terms) do
    if other_name ~= name and other_term:is_open() then
      other_term:close()
    end
  end

  term:open(ai_panel_width(), "vertical")
  vim.schedule(function()
    if term:is_open() and vim.api.nvim_get_current_buf() == term.bufnr then
      vim.cmd("startinsert")
    end
  end)
end

vim.keymap.set("n", "<C-\\>", toggle_bottom, { desc = "Toggle bottom terminal" })
vim.keymap.set("t", "<C-\\>", [[<C-\><C-n><Cmd>1ToggleTerm direction=horizontal<CR>]], { desc = "Toggle bottom terminal" })

vim.keymap.set("n", "<C-`>", toggle_bottom, { desc = "Toggle bottom terminal" })
vim.keymap.set("t", "<C-`>", [[<C-\><C-n><Cmd>1ToggleTerm direction=horizontal<CR>]], { desc = "Toggle bottom terminal" })
vim.keymap.set("n", "<C-~>", toggle_bottom, { desc = "Toggle bottom terminal" })
vim.keymap.set("t", "<C-~>", [[<C-\><C-n><Cmd>1ToggleTerm direction=horizontal<CR>]], { desc = "Toggle bottom terminal" })

vim.keymap.set("n", "<leader><CR>", toggle_float, { desc = "Toggle floating terminal" })
vim.keymap.set("t", "<leader><CR>", [[<C-\><C-n><Cmd>99ToggleTerm direction=float<CR>]], { desc = "Toggle floating terminal" })
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>Tf", function()
  toggle_float()
end, { desc = "Toggle floating terminal" })
vim.keymap.set("n", "<leader>Tb", toggle_bottom, { desc = "Toggle bottom terminal" })
vim.keymap.set("n", "<leader>Tn", "<Cmd>TermNew direction=horizontal<CR>", { desc = "New bottom terminal" })
vim.keymap.set("n", "<leader>Ts", "<Cmd>TermSelect<CR>", { desc = "Select terminal" })

vim.keymap.set("n", "<leader>ac", function()
  toggle_ai("codex")
end, { desc = "Toggle Codex terminal" })
vim.keymap.set("t", "<leader>ac", [[<C-\><C-n><Cmd>lua require("config.toggleterm").toggle_ai("codex")<CR>]], {
  desc = "Toggle Codex terminal",
})

vim.keymap.set("n", "<leader>ap", function()
  toggle_ai("pi")
end, { desc = "Toggle pi terminal" })
vim.keymap.set("t", "<leader>ap", [[<C-\><C-n><Cmd>lua require("config.toggleterm").toggle_ai("pi")<CR>]], {
  desc = "Toggle pi terminal",
})

return {
  toggle_ai = toggle_ai,
}
