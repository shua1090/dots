return {
  "s1n7ax/nvim-window-picker",
  name = "window-picker",
  version = "2.*",
  event = "VeryLazy",
  config = function()
    require("window-picker").setup({
      hint = "floating-big-letter",
      selection_chars = "1234567890FJDKSLA;CMRUEIWOQP",
      filter_rules = {
        bo = {
          filetype = {
            "neo-tree",
            "neo-tree-popup",
            "notify",
            "noice",
            "snacks_notif",
          },
          buftype = {
            "terminal",
            "quickfix",
          },
        },
      },
    })
  end,
}
