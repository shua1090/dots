-- ~/.config/nvim/init.lua
vim.loader.enable()

require("core.options")
require("core.keymaps")
require("config.latex")
require("core.lazy")
require("core.local_config")
require("config.marks").setup()

-- Theme
vim.cmd.colorscheme("onedark")
