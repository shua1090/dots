return {
  "folke/tokyonight.nvim",
  lazy = false,      -- load at startup
  priority = 1000,   -- load before other UI plugins
  opts = {
    style = "night", -- night | storm | moon | day
    transparent = false,
    terminal_colors = true,
  },
}

