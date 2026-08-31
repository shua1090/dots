vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "1"
vim.opt.fillchars:append({
  foldopen = "",
  foldclose = "",
  foldsep = " ",
})

-- Keep the usual <CR> behavior except when the cursor is on a closed fold.
vim.keymap.set("n", "<CR>", function()
  if vim.fn.foldclosed(vim.fn.line(".")) ~= -1 then
    return "zo"
  end
  return "<CR>"
end, { expr = true, desc = "Open fold or move down" })
