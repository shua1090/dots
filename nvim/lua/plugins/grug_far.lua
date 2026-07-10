return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  opts = {
    headerMaxWidth = 80,
    helpLine = { enabled = false },
  },
  keys = {
    {
      "<leader>fr",
      function()
        require("grug-far").open({ transient = true })
      end,
      desc = "Find/replace",
    },
  },
}
