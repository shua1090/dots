return {
  "nxuv/just.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = {
    "Just",
    "JustSelect",
    "JustStop",
    "JustCreateTemplate",
  },
  keys = {
    { "<leader>J", "<cmd>JustSelect<CR>", desc = "Just targets" },
  },
  opts = {
    register_commands = true,
    open_qf_on_error = true,
    open_qf_on_run = false,
  },
}
