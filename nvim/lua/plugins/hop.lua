
-- ~/.config/nvim/lua/plugins/hop.lua
return {
  "phaazon/hop.nvim",
  branch = "v2",
  keys = { "gw" },
  config = function()
    require("config.hop")
  end,
}
