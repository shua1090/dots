-- ~/.config/nvim/lua/config/oil.lua

require("oil").setup({
    default_file_explorer = true, -- replaces netrw
    columns = {
        "icon",
        -- "permissions",
        "size",
        -- "mtime",
        "git_status"
    },
    view_options = {
        show_hidden = false,
    },
    float = {
        padding = 2,
        max_width = 80,
        max_height = 30,
        border = "rounded",
        win_options = { winblend = 0 }
    }
})

vim.keymap.set("n", "<leader>i", function()
    local oil = require("oil")
    local bufname = vim.api.nvim_buf_get_name(0)

    if bufname:match("^oil://") then
        vim.cmd("close")
    else
        oil.open_float()
    end
end, { desc = "Toggle file explorer (Oil float)" })
