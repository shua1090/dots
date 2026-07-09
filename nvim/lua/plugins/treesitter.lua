-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        {
            "windwp/nvim-ts-autotag",
            opts = {},
        },
    },
    config = function()
        require("config.treesitter")
    end,
}
