return {
  "ldelossa/gh.nvim",
  dependencies = {
    {
      "ldelossa/litee.nvim",
      config = function()
        require("litee.lib").setup()
      end,
    },
  },
  config = function()
    require("litee.gh").setup()
  end,
  keys = {
    { "<leader>gh", "<cmd>GHOpenPR<cr>", desc = "GitHub: Open PR" },
  },
}
