-- ~/.config/nvim/init.lua
require("core.options")
require("core.keymaps")
require("core.lazy")
require("config.marks").setup()

-- Theme
vim.cmd.colorscheme("tokyonight")
