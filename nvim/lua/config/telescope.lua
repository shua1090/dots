local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
  defaults = {
        mappings = {
            i = {
                ["<Esc>"] = "close",
            },
        },
  },
})

vim.keymap.set("n", "<C-f>", builtin.current_buffer_fuzzy_find, { desc = "Find in buffer (Telescope)" })

-- Project picking
require("telescope").load_extension("projects")


vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
vim.keymap.set("n", "<leader>fs", builtin.treesitter, {
    desc = "Find symbols (current file)",
})

vim.keymap.set("n", "<leader>pp", function()
  require("telescope").extensions.projects.projects({})
end, { desc = "Pick project" })
