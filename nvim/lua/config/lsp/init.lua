local builtin = require("telescope.builtin")
local util = require("lspconfig.util")

vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    source = "if_many",
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
    focusable = false,
  },
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  focusable = false,
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
  focusable = false,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- Navigation
    map("n", "<leader>ld", builtin.lsp_definitions, "Go to definition")
    map("n", "<leader>lD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "<leader>li", builtin.lsp_implementations, "Go to implementation")
    map("n", "<leader>lr", builtin.lsp_references, "Find references")

    -- Info & actions
    map("n", "K", vim.lsp.buf.hover, "Hover documentation")
    map("n", "<leader>le", function()
      vim.diagnostic.open_float(nil, {
        border = "rounded",
        scope = "cursor",
        source = "if_many",
        focusable = false,
      })
    end, "Show diagnostics at cursor")
    map("n", "<leader>lR", vim.lsp.buf.rename, "Rename symbol")
    map({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, "Code actions")
    map("n", "<leader>lf", function()
      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      for _, client in ipairs(clients) do
        if client.supports_method("textDocument/formatting") then
          vim.lsp.buf.format({ bufnr = bufnr, async = true })
          return
        end
      end
      vim.notify("No LSP formatter attached for this buffer", vim.log.levels.WARN)
    end, "Format buffer")

    -- Diagnostics
    map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    map("n", "<leader>lS", builtin.lsp_workspace_symbols, "Workspace symbols")

    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      map("n", "<leader>lh", function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
      end, "Toggle inlay hints")
    end
  end,
})

-- Capabilities (extend with completion if available)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

vim.lsp.config("*", {
  capabilities = capabilities,
})

vim.lsp.config("pyright", {
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)

    local root = vim.fs.root(fname, {
      "pyproject.toml",
      "pyrightconfig.json",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
    }) or vim.fs.root(fname, { ".git" })

    vim.notify("pyright root: " .. tostring(root))

    if root then
      on_dir(root)
    end
  end,

  before_init = function(_, config)
    config.settings = config.settings or {}
    config.settings.python = config.settings.python or {}

    local root = config.root_dir
    if not root then
      return
    end

    local python = root .. "/.venv/bin/python"
    vim.notify("pyright python: " .. python)

    if vim.fn.executable(python) == 1 then
      config.settings.python.pythonPath = python
    end
  end,

  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
})

vim.lsp.config("rust_analyzer", {
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      completion = {
        autoimport = {
          enable = true,
        },
        callable = {
          snippets = "fill_arguments",
        },
        fullFunctionSignatures = {
          enable = true,
        },
        postfix = {
          enable = true,
        },
        termSearch = {
          enable = true,
        },
      },
      check = {
        command = "clippy",
      },
    },
  },
})

vim.lsp.enable({
  "pyright",
  "rust_analyzer",
  "clangd",
  "zls",
  "gopls",
  "jdtls",
})

--
-- local lspconfig = require("lspconfig")
--
-- lspconfig.clangd.setup({
--   capabilities = capabilities,
--   cmd = {
--       "clangd",
--       "--background-index",
--       "--clang-tidy",
--       "--completion-style=detailed",
--       "--query-driver=/home/shynn/.platformio/packages/**/bin/*",
--     }
--
-- })
