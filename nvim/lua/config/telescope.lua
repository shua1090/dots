local telescope = require("telescope")

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<Esc>"] = "close",
        ["<C-t>"] = function(prompt_bufnr)
          require("trouble.sources.telescope").open(prompt_bufnr)
        end,
      },
      n = {
        ["<C-t>"] = function(prompt_bufnr)
          require("trouble.sources.telescope").open(prompt_bufnr)
        end,
      },
    },
  },
  extensions = {
    ["ui-select"] = require("telescope.themes").get_dropdown({}),
  },
})

pcall(telescope.load_extension, "projects")
pcall(telescope.load_extension, "ui-select")
