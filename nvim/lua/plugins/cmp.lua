return {
  "saghen/blink.cmp",
  version = "1.*",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "rafamadriz/friendly-snippets",
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      config = function()
        local luasnip = require("luasnip")
        luasnip.config.setup({
          history = true,
          delete_check_events = "InsertLeave",
        })
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").lazy_load({
          paths = vim.fn.stdpath("config") .. "/lua/snippets",
        })
      end,
    },
  },
  opts = {
    snippets = {
      preset = "luasnip",
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 180,
        window = {
          border = "rounded",
        },
      },
      list = {
        selection = {
          preselect = false,
          auto_insert = false,
        },
      },
      menu = {
        border = "rounded",
        draw = {
          treesitter = { "lsp" },
        },
      },
    },
    keymap = {
      preset = "enter",
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide" },
      ["<C-y>"] = { "select_and_accept" },
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        buffer = {
          min_keyword_length = 3,
          max_items = 8,
        },
      },
    },
    cmdline = {
      enabled = true,
      keymap = {
        preset = "cmdline",
      },
      completion = {
        menu = {
          auto_show = function()
            return vim.fn.getcmdtype() == ":"
          end,
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
      },
    },
    fuzzy = {
      implementation = "prefer_rust",
    },
    signature = {
      enabled = true,
      window = {
        border = "rounded",
      },
    },
  },
}
