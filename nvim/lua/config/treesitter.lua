-- ~/.config/nvim/lua/config/treesitter.lua

require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "c",
        "cpp",
        "rust",
        "python",
        "lua",
        "bash",
        "java",
    },

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
})
