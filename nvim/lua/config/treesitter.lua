-- ~/.config/nvim/lua/config/treesitter.lua

require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "diff",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "html",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "latex",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "bibtex",
    },

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
        },
    },
    autotag = {
        enable = true,
    },
})

local textobjects = require("nvim-treesitter-textobjects")
textobjects.setup({
    move = {
        set_jumps = true,
    },
})

local move = require("nvim-treesitter-textobjects.move")
local function map_move(lhs, method, query, desc)
    vim.keymap.set({ "n", "x", "o" }, lhs, function()
        move[method](query, "textobjects")
    end, { desc = desc })
end

map_move("]f", "goto_next_start", "@function.outer", "Next function")
map_move("]F", "goto_next_end", "@function.outer", "End of next function")
map_move("[f", "goto_previous_start", "@function.outer", "Previous function")
map_move("[F", "goto_previous_end", "@function.outer", "Start of previous function")

map_move("]c", "goto_next_start", "@class.outer", "Next class")
map_move("]C", "goto_next_end", "@class.outer", "End of next class")
map_move("[c", "goto_previous_start", "@class.outer", "Previous class")
map_move("[C", "goto_previous_end", "@class.outer", "Start of previous class")

map_move("]a", "goto_next_start", "@parameter.inner", "Next parameter")
map_move("]A", "goto_next_end", "@parameter.inner", "End of next parameter")
map_move("[a", "goto_previous_start", "@parameter.inner", "Previous parameter")
map_move("[A", "goto_previous_end", "@parameter.inner", "Start of previous parameter")

local incremental_selection = require("nvim-treesitter.incremental_selection")
local function map_incremental(mode, lhs, method, desc)
    vim.keymap.set(mode, lhs, function()
        local ok, parser = pcall(vim.treesitter.get_parser, 0)
        if ok and parser then
            incremental_selection[method]()
        end
    end, { desc = desc })
end

map_incremental("n", "<C-Space>", "init_selection", "Start Treesitter selection")
map_incremental("x", "<C-Space>", "node_incremental", "Expand Treesitter selection")
map_incremental("x", "<BS>", "node_decremental", "Shrink Treesitter selection")
