local function executable_linter_names(lint, names)
  local available = {}
  for _, name in ipairs(names) do
    local linter = lint.linters[name]
    local cmd = linter and linter.cmd
    if type(cmd) == "function" then
      cmd = cmd()
    end
    if type(cmd) == "string" and vim.fn.executable(cmd) == 1 then
      table.insert(available, name)
    end
  end
  return available
end

local function try_lint()
  local lint = require("lint")
  local names = lint.linters_by_ft[vim.bo.filetype] or {}
  lint.try_lint(executable_linter_names(lint, names))
end

return {
  "mfussenegger/nvim-lint",
  event = {
    "BufReadPost",
    "BufNewFile",
  },
  keys = {
    { "<leader>lL", try_lint, desc = "Lint buffer" },
  },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      bash = { "shellcheck" },
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      lua = { "selene" },
      python = { "ruff" },
      sh = { "shellcheck" },
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      zsh = { "zsh" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("user_lint", { clear = true }),
      callback = try_lint,
    })
  end,
}
