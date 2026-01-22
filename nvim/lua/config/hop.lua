-- ~/.config/nvim/lua/config/hop.lua

local hop = require("hop")
local directions = require("hop.hint").HintDirection

hop.setup({
    keys = "asdfghjklqwertyuiop",
    dim_unmatched = true,
})

vim.keymap.del("n", "gw")
vim.keymap.del("x", "gw")
vim.keymap.del("o", "gw")

vim.keymap.set({ "n", "x", "o" }, "gw", function()
  require("hop").hint_words()
end, { desc = "Hop to visible word" })

