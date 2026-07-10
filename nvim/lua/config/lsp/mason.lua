require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    "pyright",
    "rust_analyzer",
    "clangd",
    "zls",
    "jdtls",
    "texlab",
  },
  automatic_enable = false,
})
