-- ~/.config/nvim/lua/config/hop.lua

local hop = require("hop")
local directions = require("hop.hint").HintDirection

hop.setup({
    keys = "asdfghjklqwertyuiop",
    dim_unmatched = true,
})

vim.keymap.set({ "n", "x", "o" }, "<leader>w", function()
    hop.hint_words()
end, { desc = "Hop to visible word" })
