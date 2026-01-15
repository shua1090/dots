return {
  "ahmedkhalf/project.nvim",
  lazy = false, -- REQUIRED: must load before VimEnter
  priority = 100, -- load early, but after colorscheme
  config = function()
      require("config.project")
  end,
}


