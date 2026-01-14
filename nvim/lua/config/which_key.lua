local wk = require("which-key")

wk.setup({
    -- Keep this non-zero so leader-chords like <leader>ff still work
    delay = 150,
    win = {
        border = "rounded",
    },
})
