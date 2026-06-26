-- ~/.config/nvim/lua/plugins/which_key.lua

return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        require("config.which_key")
    end,
}
