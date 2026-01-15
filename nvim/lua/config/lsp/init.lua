local lspconfig = require("lspconfig")

-- Shared on_attach: runs when a server attaches to a buffer
local on_attach = function(_, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  -- Navigation
  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
  map("n", "gr", vim.lsp.buf.references, "Find references")

  -- Info & actions
  -- map("n", "K", vim.lsp.buf.hover, "Hover documentation")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code actions")

  -- Diagnostics
  -- map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
  -- map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  -- map("n", "<leader>e", vim.diagnostic.open_float, "Diagnostic details")
end

-- Capabilities (completion later will extend this)
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Servers
lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

lspconfig.clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

