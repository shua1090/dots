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
    width = 24,
    max_width = 48,
    auto_expand_width = true,
    mappings = {
      ["<space>"] = "none", -- avoid conflicts
    },
  },
  event_handlers = {
    {
      event = "after_render",
      id = "auto_resize_width",
      handler = function(state)
        if not state or not state.winid or state.current_position == "float" then
          return
        end

        local wininfo = vim.fn.getwininfo(state.winid)
        if not wininfo[1] then
          return
        end

        local textoff = wininfo[1].textoff or 0
        local desired = (state.longest_node or 0) + textoff
        local min_width = state.window.width or 24
        local max_width = state.window.max_width
        if max_width then
          desired = math.min(desired, max_width)
        end
        desired = math.max(desired, min_width)

        local current = vim.api.nvim_win_get_width(state.winid)
        if desired ~= current then
          vim.api.nvim_win_set_width(state.winid, desired)
          state.win_width = desired
        end
      end,
    },
  },
})

vim.keymap.set("n", "<leader>e", function()
  vim.cmd("Neotree filesystem toggle left")
end, { desc = "Explorer (neo-tree)" })
