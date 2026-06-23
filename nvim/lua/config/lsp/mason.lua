require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",
    "rust_analyzer",
    "clangd",
    "jdtls",
    "texlab",
  },
  automatic_installation = true,
})
