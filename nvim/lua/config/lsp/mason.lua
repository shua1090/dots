require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",
    "rust_analyzer",
    "clangd",
    "zls",
    "gopls",
  },
  automatic_installation = true,
})
