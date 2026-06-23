vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.exrc = true

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
opt.autoread = true

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

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  desc = "Reload buffers when files change on disk",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  desc = "Notify when a buffer is reloaded from disk",
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)
    vim.notify(
      "Reloaded " .. vim.fn.fnamemodify(name, ":~:."),
      vim.log.levels.INFO,
      { title = "File changed on disk" }
    )
  end,
})

-- vim.opt.timeout = true
-- vim.opt.timeoutlen = 300
--
