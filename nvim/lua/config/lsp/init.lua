local builtin = require("telescope.builtin")

vim.g.lsp_autoshow_enabled = vim.g.lsp_autoshow_enabled ~= false

local function close_autoshow_floats()
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(winid)
    if cfg.relative ~= "" then
      local ok, is_autoshow = pcall(vim.api.nvim_win_get_var, winid, "lsp_autoshow_float")
      if ok and is_autoshow then
        pcall(vim.api.nvim_win_close, winid, true)
      end
    end
  end
end

local function open_diagnostic_float(opts)
  local _, winid = vim.diagnostic.open_float(nil, vim.tbl_extend("force", {
    focus = false,
    focusable = false,
    border = "rounded",
    close_events = { "CursorMoved", "CursorMovedI", "InsertCharPre", "WinScrolled" },
  }, opts or {}))
  if winid and vim.api.nvim_win_is_valid(winid) then
    pcall(vim.api.nvim_win_set_var, winid, "lsp_autoshow_float", true)
  end
end

local base_hover_handler = vim.lsp.handlers.hover
vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
  local bufnr, winid = base_hover_handler(err, result, ctx, vim.tbl_extend("force", {
    border = "rounded",
    focusable = false,
    close_events = { "CursorMoved", "CursorMovedI", "InsertCharPre", "WinScrolled" },
  }, config or {}))

  if winid and vim.api.nvim_win_is_valid(winid) then
    pcall(vim.api.nvim_win_set_var, winid, "lsp_autoshow_float", true)
  end

  return bufnr, winid
end

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
    -- map("n", "K", vim.lsp.buf.hover, "Hover documentation")
    map("n", "<leader>lR", vim.lsp.buf.rename, "Rename symbol")
    map("n", "<leader>la", vim.lsp.buf.code_action, "Code actions")
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
    -- map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    -- map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    -- map("n", "<leader>e", vim.diagnostic.open_float, "Diagnostic details")
    map("n", "<leader>lq", builtin.diagnostics, "Diagnostics (workspace)")
    map("n", "<leader>ls", builtin.lsp_document_symbols, "Document symbols")
    map("n", "<leader>lS", builtin.lsp_workspace_symbols, "Workspace symbols")

    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      map("n", "<leader>lh", function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
      end, "Toggle inlay hints")
    end

    map("n", "<leader>lw", function()
      vim.g.lsp_autoshow_enabled = not vim.g.lsp_autoshow_enabled
      if not vim.g.lsp_autoshow_enabled then
        close_autoshow_floats()
      end

      vim.notify(
        ("LSP autoshow %s"):format(vim.g.lsp_autoshow_enabled and "enabled" or "disabled"),
        vim.log.levels.INFO,
        { title = "LSP" }
      )
    end, "Toggle LSP autoshow")

    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = bufnr,
      callback = function()
        if not vim.g.lsp_autoshow_enabled then
          return
        end

        local pos = vim.api.nvim_win_get_cursor(0)
        local diags = vim.diagnostic.get(0, { lnum = pos[1] - 1 })
        if #diags > 0 then
          open_diagnostic_float({
            source = "always",
            scope = "cursor",
            max_width = 80,
          })
        else
          vim.lsp.buf.hover()
        end
      end,
      desc = "Show diagnostic or hover on idle",
    })
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

vim.lsp.enable({
  "pyright",
  "rust_analyzer",
  -- "clangd",
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
