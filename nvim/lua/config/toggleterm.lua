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
