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
  },
  window = {
    width = 32,
    mappings = {
      ["<space>"] = "none", -- avoid conflicts
    },
  },
})

vim.keymap.set("n", "<leader>e", function()
  vim.cmd("Neotree filesystem toggle left")
end, { desc = "Explorer (neo-tree)" })


