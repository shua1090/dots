local theta = require("alpha.themes.theta")
local dashboard = require("alpha.themes.dashboard")
local uv = vim.loop

-- Allow overriding in init.lua or user commands: vim.g.alpha_favorite_projects = { { name = "proj", path = "~/proj" }, ... }
local favorite_projects = vim.g.alpha_favorite_projects or {
  { name = "dots", path = "~/Documents/dots" },
  { name = "px4", path = "~/Documents/Mach/px4" },
  { name = "monorepo", path = "~/Projects/Mach/monorepo" },
}

local apple_art = [[

⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⡿⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣠⣤⣤⣤⣀⣀⠈⠋⠉⣁⣠⣤⣤⣤⣀⡀⠀⠀
⠀⢠⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀
⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀
⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀
⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣀
⠀⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁
⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁⠀
⠀⠀⠀⠈⠙⢿⣿⣿⣿⠿⠟⠛⠻⠿⣿⣿⣿⡿⠋⠀⠀⠀
]];

local penguin_art = [[
    Linux!
]];


local function os_block()
  local sysname = uv.os_uname().sysname
  local art = sysname == "Darwin" and apple_art or penguin_art
  local label = sysname == "Darwin" and "macOS detected" or "Linux detected"

  return {
    type = "group",
    val = {
      { type = "text", val = art, opts = { position = "center", hl = "Type" } },
      { type = "text", val = label, opts = { position = "center", hl = "Title" } },
    },
  }
end

local function expand_path(path)
  return vim.fn.fnamemodify(vim.fn.expand(path), ":p")
end

local function project_button(shortcut, label, path)
  local full_path = expand_path(path)
  local exists = uv.fs_stat(full_path) ~= nil
  local cd_path = vim.fn.fnameescape(full_path)

  local command
  if exists then
    command = string.format("<cmd>cd %s | Telescope find_files<CR>", cd_path)
  else
    command = string.format("<cmd>echo 'Path not found: %s'<CR>", full_path)
  end

  local text = exists and label or (label .. " (missing)")
  return dashboard.button(shortcut, text, command)
end

local function favorite_section()
  local buttons = {}
  for idx, project in ipairs(favorite_projects) do
    if project.name and project.path then
      local label = string.format("%d. %s", idx, project.name)
      table.insert(buttons, project_button("f" .. idx, label, project.path))
    end
  end

  if #buttons == 0 then
    return { type = "text", val = "Add favorite_projects in config.alpha", opts = { position = "center", hl = "Comment" } }
  end

  return {
    type = "group",
    val = buttons,
    opts = { position = "center", spacing = 0 },
  }
end

local recent_projects = {
  type = "group",
  val = function()
    local ok, project = pcall(require, "project_nvim")
    if not ok or not project.get_recent_projects then
      return { { type = "text", val = "project.nvim not available", opts = { position = "center", hl = "Comment" } } }
    end

    local projects = project.get_recent_projects()
    local buttons = {}
    local shown = 0
    for _, path in ipairs(projects) do
      if shown == 5 then
        break
      end
      shown = shown + 1
      local name = vim.fn.fnamemodify(path, ":t")
      local label = string.format("%d. %s", shown, name)
      table.insert(buttons, project_button("p" .. shown, label, path))
    end

    if #buttons == 0 then
      return { { type = "text", val = "No recent projects yet", opts = { position = "center", hl = "Comment" } } }
    end

    return buttons
  end,
  opts = { position = "center", spacing = 0 },
}

local recent_files = {
  type = "group",
  val = {
    {
      type = "text",
      val = "Recent files",
      opts = { hl = "SpecialComment", position = "center" },
    },
    { type = "padding", val = 1 },
    {
      type = "group",
      val = function()
        return { theta.mru(0, vim.fn.getcwd()) }
      end,
      opts = { shrink_margin = false },
    },
  },
}

local quick_links = {
  type = "group",
  val = {
    { type = "text", val = "Quick links", opts = { hl = "SpecialComment", position = "center" } },
    { type = "padding", val = 1 },
    dashboard.button("e", "  New file", "<cmd>ene<CR>"),
    dashboard.button("SPC f f", "󰈞  Find file", "<cmd>Telescope find_files<CR>"),
    dashboard.button("SPC f g", "󰊄  Live grep", "<cmd>Telescope live_grep<CR>"),
    dashboard.button("u", "  Update plugins", "<cmd>Lazy sync<CR>"),
    dashboard.button("q", "󰅚  Quit", "<cmd>qa<CR>"),
  },
  opts = { position = "center" },
}

local layout = {
  { type = "padding", val = 2 },
  os_block(),
  { type = "padding", val = 2 },
  { type = "text", val = "Favorites", opts = { position = "center", hl = "SpecialComment" } },
  { type = "padding", val = 1 },
  favorite_section(),
  { type = "padding", val = 1 },
  { type = "text", val = "Recent projects", opts = { position = "center", hl = "SpecialComment" } },
  { type = "padding", val = 1 },
  recent_projects,
  { type = "padding", val = 2 },
  recent_files,
  { type = "padding", val = 2 },
  quick_links,
}

local config = {
  layout = layout,
  opts = {
    margin = 4,
    redraw_on_resize = false,
    setup = function()
      local group = vim.api.nvim_create_augroup("AlphaCustomDashboard", { clear = true })
      vim.api.nvim_create_autocmd("DirChanged", {
        pattern = "*",
        group = group,
        callback = function()
          -- Only redraw when we are actually on a live alpha buffer.
          vim.schedule(function()
            local buf = vim.api.nvim_get_current_buf()
            if not buf or not vim.api.nvim_buf_is_valid(buf) then
              return
            end
            if vim.bo[buf].filetype ~= "alpha" then
              return
            end
            local ok_alpha, alpha = pcall(require, "alpha")
            if not ok_alpha then
              return
            end
            pcall(alpha.redraw)
          end)
        end,
      })
    end,
  },
}

require("alpha").setup(config)
