return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("config.aerial")
    end,
}
