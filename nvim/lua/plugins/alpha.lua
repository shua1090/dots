return {
    'goolord/alpha-nvim',
    dependencies = {
        'nvim-mini/mini.icons',
        'nvim-lua/plenary.nvim'
    },
    config = function ()
        require("config.alpha")
    end
};
