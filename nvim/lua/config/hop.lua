-- ~/.config/nvim/lua/config/hop.lua

local hop = require("hop")
hop.setup({
    keys = "asdfghjklqwertyuiop",
    dim_unmatched = true,
})

pcall(vim.keymap.del, "n", "gw")
pcall(vim.keymap.del, "x", "gw")
pcall(vim.keymap.del, "o", "gw")

vim.keymap.set({ "n", "x", "o" }, "gw", function()
  require("hop").hint_words()
end, { desc = "Hop to visible word" })
