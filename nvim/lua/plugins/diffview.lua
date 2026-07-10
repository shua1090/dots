return {
  "sindrets/diffview.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewFileHistory",
    "DiffviewRefresh",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff view" },
    { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close git diff view" },
    { "<leader>gF", "<cmd>DiffviewFileHistory %<cr>", desc = "Git file history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Git repo history" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      merge_tool = {
        layout = "diff3_mixed",
      },
    },
    file_panel = {
      listing_style = "tree",
      tree_options = {
        flatten_dirs = true,
        folder_statuses = "only_folded",
      },
    },
  },
}
