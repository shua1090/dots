vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.hlsearch = false
opt.updatetime = 500

opt.termguicolors = true
opt.signcolumn = "yes"

opt.clipboard = "unnamedplus"

-- I don't want mouse enabled
vim.opt.mouse = ""

vim.o.list = true
vim.o.listchars = 'tab:» ,lead:•,trail:•'

-- Smoother diffs (closer to VSCode visuals)
opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "context:3",
  "algorithm:histogram",
  "indent-heuristic",
  "linematch:60",
}
opt.fillchars:append({ diff = " " })

-- vim.opt.timeout = true
-- vim.opt.timeoutlen = 300
--
