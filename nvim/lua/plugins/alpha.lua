return {
   'goolord/alpha-nvim',
   event = "VimEnter",
   dependencies = {
       'nvim-mini/mini.icons',
       'nvim-lua/plenary.nvim'
    },
    config = function ()
        require("config.alpha")
    end
};
