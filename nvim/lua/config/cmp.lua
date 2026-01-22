local cmp = require("cmp")

vim.opt.completeopt = { "menu", "menuone", "noselect" }

cmp.setup({
  snippet = {
    expand = function(args)
      if vim.snippet and vim.snippet.expand then
        vim.snippet.expand(args.body)
      end
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "buffer" },
  }),
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, item)
      local menu = {
        nvim_lsp = "[LSP]",
        buffer = "[Buf]",
        path = "[Path]",
      }
      item.menu = menu[entry.source.name]
      return item
    end,
  },
})
