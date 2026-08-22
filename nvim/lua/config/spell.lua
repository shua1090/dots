local group = vim.api.nvim_create_augroup("user_spell", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    -- Treesitter's @spell captures and Vim's @Spell syntax clusters decide
    -- which regions are checked. This keeps ordinary code out of spellcheck.
    vim.wo.spell = true
    vim.bo[args.buf].spelllang = "en_us"
    vim.bo[args.buf].spelloptions = "noplainbuffer"
    vim.cmd("syntax spell notoplevel")
  end,
})
