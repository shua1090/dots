local function fzf_lsp(method, opts)
  return function()
    require("fzf-lua")[method](opts or {})
  end
end

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

vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {
  undercurl = true,
  sp = "#e0af68",
})

local function with(handler, opts)
  return function(err, result, ctx, config)
    return handler(err, result, ctx, vim.tbl_deep_extend("force", config or {}, opts))
  end
end

vim.lsp.handlers["textDocument/hover"] = with(vim.lsp.handlers.hover, {
  border = "rounded",
  focusable = false,
})

vim.lsp.handlers["textDocument/signatureHelp"] = with(vim.lsp.handlers.signature_help, {
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
    map("n", "<leader>ld", fzf_lsp("lsp_definitions", { jump1 = true, ignore_current_line = true }), "Go to definition")
    map("n", "<leader>lD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "<leader>li", fzf_lsp("lsp_implementations", { jump1 = true, ignore_current_line = true }), "Go to implementation")
    map("n", "<leader>lr", fzf_lsp("lsp_references", { jump1 = true, ignore_current_line = true }), "Find references")

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
    map({ "n", "x" }, "<leader>la", fzf_lsp("lsp_code_actions", { silent = true }), "Code actions")
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
    map("n", "<leader>lS", fzf_lsp("lsp_live_workspace_symbols"), "Workspace symbols")

    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      map("n", "<leader>lh", function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
      end, "Toggle inlay hints")
    end
  end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

vim.lsp.config("*", {
  capabilities = capabilities,
})

vim.lsp.config("rust_analyzer", vim.tbl_deep_extend("force", vim.lsp.config.rust_analyzer or {}, {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allTargets = false,
      },
      check = {
        allTargets = false,
      },
    },
  },
}))

local python_root_markers = {
  ".venv",
  "uv.lock",
  "pyproject.toml",
  "pyrightconfig.json",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  ".git",
}

local function has_marker(dir, markers)
  for _, marker in ipairs(markers) do
    if vim.uv.fs_stat(vim.fs.joinpath(dir, marker)) then
      return true
    end
  end
  return false
end

local function nearest_marker_dir(path, markers)
  local stat = vim.uv.fs_stat(path)
  local dir = stat and stat.type == "directory" and path or vim.fs.dirname(path)

  while dir and dir ~= "" do
    if has_marker(dir, markers) then
      return dir
    end

    local parent = vim.fs.dirname(dir)
    if not parent or parent == dir then
      return nil
    end
    dir = parent
  end
end

local function nearest_venv(path)
  local root = nearest_marker_dir(path, { ".venv" })
  if not root then
    return nil
  end

  local python = vim.fs.joinpath(root, ".venv", "bin", "python")
  if vim.fn.executable(python) ~= 1 then
    return nil
  end

  return {
    python = python,
    venv = ".venv",
    venv_path = root,
  }
end

vim.lsp.config("pyright", {
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local root = nearest_marker_dir(fname, python_root_markers)

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

    local venv = nearest_venv(root)
    if venv then
      config.settings.python.pythonPath = venv.python
      config.settings.python.venv = venv.venv
      config.settings.python.venvPath = venv.venv_path
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

vim.lsp.config("texlab", {
  capabilities = capabilities,
  settings = {
    texlab = {
      build = {
        executable = "pdflatex",
        args = { "-interaction=nonstopmode", "-synctex=1", "%f" },
        onSave = false,
        forwardSearchAfter = false,
      },
      chktex = {
        onOpenAndSave = false,
        onEdit = false,
      },
    },
  },
})

vim.lsp.enable({
  "pyright",
  "rust_analyzer",
  "zls",
  "gopls",
  "texlab",
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
