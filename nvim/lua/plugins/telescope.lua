return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
        {
            "<C-f>",
            function()
                require("telescope.builtin").current_buffer_fuzzy_find()
            end,
            desc = "Find in buffer (Telescope)",
        },
        {
            "<leader>ff",
            function()
                require("telescope.builtin").find_files()
            end,
            desc = "Find files",
        },
        {
            "<leader>fg",
            function()
                require("telescope.builtin").live_grep()
            end,
            desc = "Live grep",
        },
        {
            "<leader>fb",
            function()
                require("telescope.builtin").buffers()
            end,
            desc = "Buffers",
        },
        {
            "<leader>fh",
            function()
                require("telescope.builtin").help_tags()
            end,
            desc = "Help",
        },
        {
            "<leader>fs",
            function()
                require("telescope.builtin").treesitter()
            end,
            desc = "Find symbols (current file)",
        },
        {
            "<leader>pp",
            function()
                require("telescope").extensions.projects.projects({})
            end,
            desc = "Pick project",
        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
        require("config.telescope")
    end,
}
