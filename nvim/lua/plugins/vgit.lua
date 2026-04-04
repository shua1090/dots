return {
  "tanvirtin/vgit.nvim",
  event = "VimEnter",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local ProjectDiffScreen = require("vgit.features.screens.ProjectDiffScreen")

    local function focus_fallback_keymaps(screen)
      return {
        {
          mode = "n",
          key = "<C-w>w",
          desc = "Switch focus between file list and diff preview",
          handler = function()
            screen:toggle_focus()
          end,
        },
        {
          mode = "n",
          key = "<C-w><C-w>",
          desc = "Switch focus between file list and diff preview",
          handler = function()
            screen:toggle_focus()
          end,
        },
      }
    end

    local original_setup_list_keymaps = ProjectDiffScreen.setup_list_keymaps
    ProjectDiffScreen.setup_list_keymaps = function(self)
      original_setup_list_keymaps(self)
      self.status_list_view:set_keymap(focus_fallback_keymaps(self))
    end

    local original_setup_diff_keymaps = ProjectDiffScreen.setup_diff_keymaps
    ProjectDiffScreen.setup_diff_keymaps = function(self)
      original_setup_diff_keymaps(self)
      self.diff_view:set_keymap(focus_fallback_keymaps(self))
    end

    require("vgit").setup({
      keymaps = {
        ["n <leader>gd"] = { mode = "n", key = "<leader>gd", handler = "project_diff_preview", desc = "Project diff preview" },
        ["n <leader>gf"] = { mode = "n", key = "<leader>gf", handler = "buffer_diff_preview", desc = "Buffer diff preview" },
        ["n <leader>gF"] = { mode = "n", key = "<leader>gF", handler = "project_logs_preview", desc = "Project logs preview" },
        ["n <leader>gH"] = { mode = "n", key = "<leader>gH", handler = "buffer_history_preview", desc = "Buffer history preview" },
        ["n <leader>gb"] = { mode = "n", key = "<leader>gb", handler = "buffer_blame_preview", desc = "Buffer blame preview" },
        ["n <leader>gp"] = { mode = "n", key = "<leader>gp", handler = "buffer_hunk_preview", desc = "Preview hunk" },
        ["n <leader>gr"] = { mode = "n", key = "<leader>gr", handler = "buffer_hunk_reset", desc = "Reset hunk" },
        ["n <leader>gu"] = { mode = "n", key = "<leader>gu", handler = "buffer_reset", desc = "Reset buffer" },
        ["n <leader>gx"] = { mode = "n", key = "<leader>gx", handler = "toggle_diff_preference", desc = "Toggle diff layout" },
      },
    })
  end,
}
