-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    config = function()
        require("config.treesitter")
    end,
}
