
-- ~/.config/nvim/lua/plugins/hop.lua
return {
  "smoka7/hop.nvim",
  keys = { "gw" },
  config = function()
    require("config.hop")
  end,
}
