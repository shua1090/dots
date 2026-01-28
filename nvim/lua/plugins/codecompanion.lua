return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
         "lalitmee/codecompanion-spinners.nvim",
         "folke/noice.nvim"
    },
    config = function()
        require("config.codecompanion")
    end,
}
