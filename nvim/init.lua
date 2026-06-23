-- ~/.config/nvim/init.lua
require("core.options")
require("core.keymaps")
require("config.latex")
require("core.lazy")
require("core.local_config")


-- Theme
vim.cmd.colorscheme("tokyonight")
