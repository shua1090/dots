return {
  {
    "rcarriga/nvim-notify",
    opts = {
      stages = "fade_in_slide_out",
      timeout = 2800,
      fps = 60,
      render = "wrapped-compact",
      top_down = false,
      background_colour = "#000000",
      max_width = function()
        return math.floor(vim.o.columns * 0.45)
      end,
      max_height = function()
        return math.floor(vim.o.lines * 0.25)
      end,
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
        hover = {
          enabled = true,
          opts = {
            focus = false,
            focusable = false,
          },
        },
        signature = {
          enabled = true,
          opts = {
            focus = false,
            focusable = false,
          },
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
      cmdline = {
        view = "cmdline_popup",
      },
      messages = {
        enabled = true,
        view = "notify",
        view_warn = "notify",
        view_error = "notify",
      },
      notify = {
        enabled = true,
        view = "notify",
      },
      routes = {
        {
          filter = {
            event = "notify",
            find = "No information available",
          },
          opts = { skip = true },
        },
      },
      views = {
        cmdline_popup = {
          border = { style = "rounded", padding = { 0, 1 } },
          win_options = { winblend = 8 },
        },
        hover = {
          border = { style = "rounded", padding = { 0, 1 } },
          win_options = { winblend = 0 },
        },
      },
    },
    config = function(_, opts)
      require("noice").setup(opts)
    end,
  },
}
