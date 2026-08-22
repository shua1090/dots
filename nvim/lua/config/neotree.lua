vim.g.neotree_git_status_hide_staged = vim.g.neotree_git_status_hide_staged or false

local function is_staged_only_status(status)
  if type(status) == "table" then
    status = status[1]
  end

  if type(status) ~= "string" or status == "?" or status == "!" then
    return false
  end

  local index_status = status:sub(1, 1)
  local worktree_status = status:sub(2, 2)
  if worktree_status == "" then
    worktree_status = "."
  end

  return index_status ~= "." and index_status ~= " " and worktree_status == "."
end

local function prune_staged_only_items(items, keep_empty_directories)
  local visible = {}

  for _, item in ipairs(items or {}) do
    item.children = prune_staged_only_items(item.children, false)

    local keep_directory = item.type == "directory" and (keep_empty_directories or #item.children > 0)
    local keep_file = item.type ~= "directory"
      and not is_staged_only_status(item.extra and item.extra.git_status)
    if keep_directory or keep_file then
      table.insert(visible, item)
    end
  end

  return visible
end

local function patch_git_status_filter()
  local renderer = require("neo-tree.ui.renderer")
  if renderer._git_status_hide_staged_patched then
    return
  end

  local show_nodes = renderer.show_nodes
  renderer.show_nodes = function(source_items, state, parent_id, callback)
    if vim.g.neotree_git_status_hide_staged and state and state.name == "git_status" then
      source_items = prune_staged_only_items(source_items, true)
    end

    return show_nodes(source_items, state, parent_id, callback)
  end

  renderer._git_status_hide_staged_patched = true
end

local function toggle_staged_git_status(state)
  vim.g.neotree_git_status_hide_staged = not vim.g.neotree_git_status_hide_staged
  vim.notify(
    vim.g.neotree_git_status_hide_staged and "Showing only unstaged changes"
      or "Showing staged and unstaged changes",
    vim.log.levels.INFO,
    { title = "Neo-tree git status" }
  )
  require("neo-tree.sources.manager").navigate(state, state.path)
end

patch_git_status_filter()

local function set_project_root_from_node(state)
  local node = state.tree:get_node()
  while node and node.type ~= "directory" do
    local parent_id = node:get_parent_id()
    node = parent_id and state.tree:get_node(parent_id) or nil
  end

  if not node then
    return
  end

  local path = node:get_id()
  if not path or path == "" then
    return
  end

  require("project_nvim.project").set_pwd(path, "manual")
  require("neo-tree.sources.filesystem.commands").set_root(state)
end

local function copy_node_path(state, absolute)
  local node = state.tree:get_node()
  if not node then
    return
  end

  local path = node.path or node:get_id()
  if not path or path == "" then
    return
  end

  if not absolute then
    path = vim.fs.relpath(vim.uv.cwd(), path) or path
  end

  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO, { title = "Neo-tree" })
end

local function copy_relative_path(state)
  copy_node_path(state, false)
end

local function copy_absolute_path(state)
  copy_node_path(state, true)
end

local function sidebar_width()
  return math.min(46, math.max(32, math.floor(vim.o.columns * 0.24)))
end

require("neo-tree").setup({
  default_source = "last",
  sources = {
    "filesystem",
    "buffers",
    "git_status",
  },
  close_if_last_window = true,
  popup_border_style = "rounded",
  resize_timer_interval = -1,
  enable_git_status = true,
  enable_diagnostics = false, -- LSP later
  default_component_configs = {
    indent = {
      with_expanders = true,
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    git_status = {
      symbols = {
        added = "✚",
        conflict = "",
        deleted = "✖",
        ignored = "",
        modified = "",
        renamed = "󰁕",
        unstaged = "󰄱",
        untracked = "",
        staged = "󰱒",
      },
    },
  },
  source_selector = {
    winbar = true,
    statusline = false,
    sources = {
      { source = "filesystem", display_name = " 󰉓 Files " },
      { source = "buffers", display_name = " 󰈚 Buffers " },
      { source = "git_status", display_name = " 󰊢 Git " },
    },
    tabs_layout = "equal",
    truncation_character = "…",
  },
  filesystem = {
    follow_current_file = {
      enabled = true,
    },
    group_empty_dirs = true,
    hijack_netrw_behavior = "open_default",
    use_libuv_file_watcher = true, -- performance on large repos
    window = {
      mappings = {
        ["P"] = { set_project_root_from_node, desc = "Set project root" },
        ["<C-CR>"] = "open_with_window_picker",
        ["<C-Enter>"] = "open_with_window_picker",
      },
    },
  },
  buffers = {
    follow_current_file = {
      enabled = true,
    },
    group_empty_dirs = true,
    show_unloaded = true,
  },
  git_status = {
    commands = {
      toggle_staged = toggle_staged_git_status,
    },
    window = {
      mappings = {
        ["h"] = { "toggle_staged", desc = "Toggle staged files" },
        ["<C-CR>"] = "open_with_window_picker",
        ["<C-Enter>"] = "open_with_window_picker",
      },
    },
  },
  window = {
    width = sidebar_width,
    auto_expand_width = false,
    mappings = {
      ["["] = "prev_source",
      ["]"] = "next_source",
      ["gy"] = { copy_relative_path, desc = "Copy relative path" },
      ["gY"] = { copy_absolute_path, desc = "Copy absolute path" },
      ["<space>"] = "none", -- avoid conflicts
    },
  },
})
