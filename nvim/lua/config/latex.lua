vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex", "bib" },
  desc = "LaTeX editing defaults",
  callback = function()
    vim.bo.textwidth = 88
    vim.wo.spell = true
    vim.wo.conceallevel = 0
  end,
})
