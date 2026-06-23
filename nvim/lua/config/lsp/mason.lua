require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",
    "rust_analyzer",
    "clangd",
    "zls",
    "gopls",
    "jdtls",
  },
  automatic_installation = true,
})
