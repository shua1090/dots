return {
  "echasnovski/mini.animate",
  event = "VeryLazy",
  config = function()
    local animate = require("mini.animate")
    animate.setup({
      cursor = {
        enable = true,
        timing = animate.gen_timing.linear({ duration = 90, unit = "total" }),
      },
      scroll = {
        enable = false,
        timing = animate.gen_timing.quadratic({ duration = 140, unit = "total" }),
        subscroll = animate.gen_subscroll.equal({ max_output_steps = 80 }),
      },
      resize = {
        enable = true,
        timing = animate.gen_timing.linear({ duration = 140, unit = "total" }),
      },
      open = {
        enable = true,
        timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
        winconfig = animate.gen_winconfig.static({ n_steps = 16 }),
        winblend = animate.gen_winblend.linear({ from = 90, to = 100 }),
      },
      close = {
        enable = true,
        timing = animate.gen_timing.linear({ duration = 120, unit = "total" }),
        winconfig = animate.gen_winconfig.static({ n_steps = 14 }),
        winblend = animate.gen_winblend.linear({ from = 90, to = 100 }),
      },
    })
  end,
}
