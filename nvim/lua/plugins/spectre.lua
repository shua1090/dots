return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("spectre").setup({})
  end,
  keys = {
    {
      "<leader>fr",
      function()
        require("spectre").toggle()
      end,
      desc = "Find/replace in project",
    },
    {
      "<leader>fw",
      function()
        require("spectre").open_visual({ select_word = true })
      end,
      desc = "Search current word (project)",
    },
    {
      "<leader>fp",
      function()
        require("spectre").open_file_search({ select_word = true })
      end,
      desc = "Find/replace in file",
    },
    {
      "<leader>fw",
      mode = "v",
      function()
        require("spectre").open_visual()
      end,
      desc = "Search selection (project)",
    },
  },
}
