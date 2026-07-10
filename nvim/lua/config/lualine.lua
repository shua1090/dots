local function root_dir()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return ""
  end

  local root = vim.fs.root(path, {
    ".git",
    "Makefile",
    "package.json",
    "Cargo.toml",
    "pyproject.toml",
    "go.mod",
    "pom.xml",
  })
  if not root then
    return ""
  end

  return "󱉭 " .. vim.fn.fnamemodify(root, ":t")
end

local lualine_c = {
  {
    root_dir,
    cond = function()
      return root_dir() ~= ""
    end,
    color = "Directory",
  },
  {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = {
      error = " ",
      warn = " ",
      info = " ",
      hint = " ",
    },
  },
  {
    "filetype",
    icon_only = true,
    separator = "",
    padding = { left = 1, right = 0 },
  },
  {
    "filename",
    path = 1,
    symbols = {
      modified = " ●",
      readonly = " ",
      unnamed = "[No Name]",
      newfile = "[New]",
    },
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

local lualine_x = {
  {
    function()
      return require("noice").api.status.command.get()
    end,
    cond = function()
      return package.loaded["noice"] and require("noice").api.status.command.has()
    end,
    color = "Statement",
  },
  {
    function()
      return require("noice").api.status.mode.get()
    end,
    cond = function()
      return package.loaded["noice"] and require("noice").api.status.mode.has()
    end,
    color = "Constant",
  },
  {
    require("lazy.status").updates,
    cond = require("lazy.status").has_updates,
    color = "Special",
  },
  {
    "diff",
    symbols = {
      added = " ",
      modified = " ",
      removed = " ",
    },
    source = function()
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed,
        }
      end
    end,
  },
}
require("lualine").setup({
  options = {
    theme = "auto", -- follow your colorscheme
    section_separators = "",
    component_separators = "",
    globalstatus = true,
    disabled_filetypes = {
      statusline = { "alpha", "dashboard", "snacks_dashboard" },
    },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = lualine_c,
    lualine_x = lualine_x,
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  extensions = { "neo-tree", "lazy", "fzf" },
})
