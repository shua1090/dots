local lualine_c = {
  {
    "filename",
    path = 1, -- relative path
  },
}

local ok_trouble, trouble = pcall(require, "trouble")
if ok_trouble then
  local symbols = trouble.statusline({
    mode = "lsp_document_symbols",
    groups = {},
    title = false,
    filter = { range = true },
    format = "{kind_icon}{symbol.name:Normal}",
    hl_group = "lualine_c_normal",
  })

  table.insert(lualine_c, {
    symbols.get,
    cond = symbols.has,
  })
end

local lualine_x = { "filetype" }
require("lualine").setup({
  options = {
    theme = "auto", -- follow your colorscheme
    section_separators = "",
    component_separators = "",
    globalstatus = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = lualine_c,
    lualine_x = lualine_x,
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})
