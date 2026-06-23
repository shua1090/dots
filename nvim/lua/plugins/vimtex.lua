return {
  "lervag/vimtex",
  ft = { "tex", "plaintex", "bib" },
  init = function()
    vim.g.tex_flavor = "latex"

    -- Keep LaTeX editing explicit: no VimTeX mappings and no symbol conceal.
    vim.g.vimtex_mappings_enabled = 0
    vim.g.vimtex_compiler_enabled = 0
    vim.g.tex_conceal = ""
    vim.g.vimtex_syntax_conceal_disable = 1
  end,
}
