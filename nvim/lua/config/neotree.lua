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

require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = false, -- LSP later
  filesystem = {
    follow_current_file = {
      enabled = true,
    },
    hijack_netrw_behavior = "open_default",
    use_libuv_file_watcher = true, -- performance on large repos
    window = {
      mappings = {
        ["P"] = { set_project_root_from_node, desc = "Set project root" },
      },
    },
  },
  window = {
    width = 24,
    max_width = 48,
    auto_expand_width = false,
    mappings = {
      ["<space>"] = "none", -- avoid conflicts
    },
  },
})

vim.keymap.set("n", "<leader>e", function()
  vim.cmd("Neotree filesystem toggle left")
end, { desc = "Explorer (neo-tree)" })
