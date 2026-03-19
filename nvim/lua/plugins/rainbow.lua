return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "TheGLander/indent-rainbowline.nvim",
  },
  opts = function()
    local opts = {
      indent = {
        char = "▏",
        tab_char = "▏",
        smart_indent_cap = true,
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
        show_exact_scope = true,
      },
      whitespace = {
        remove_blankline_trail = true,
      },
      exclude = {
        filetypes = {
          "aerial",
          "alpha",
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "noice",
          "notify",
          "TelescopePrompt",
          "terminal",
        },
      },
    }

    return require("indent-rainbowline").make_opts(opts, {
      color_transparency = 0.12,
    })
  end,
  config = function(_, opts)
    require("ibl").setup(opts)
  end,
}
