local home = vim.env.HOME or vim.fn.expand("$HOME")

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
   _____ __                    _    ___         
  / ___// /_  __  ______  ____| |  / (_)___ ___ 
  \__ \/ __ \/ / / / __ \/ __ \ | / / / __ `__ \
 ___/ / / / / /_/ / / / / / / / |/ / / / / / / /
/____/_/ /_/\__, /_/ /_/_/ /_/|___/_/_/ /_/ /_/ 
           /____/                               
]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua require('fzf-lua').files()" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua require('fzf-lua').live_grep()" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        {
          icon = " ",
          title = "Projects",
          section = "projects",
          indent = 2,
          padding = 1,
          dirs = {
            home .. "/Documents/dots",
            home .. "/Documents/Mach/px4",
            home .. "/Projects/Mach/monorepo",
          },
        },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { section = "startup" },
      },
    },
    quickfile = { enabled = true },
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 10, total = 160 },
        easing = "outQuad",
      },
      animate_repeat = {
        delay = 80,
        duration = { step = 5, total = 50 },
        easing = "linear",
      },
    },
    words = { enabled = true },
  },
}
