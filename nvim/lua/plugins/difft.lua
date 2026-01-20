vim.api.nvim_create_user_command("BranchDiff", function(opts)
  local args = opts.fargs
  if #args == 0 then
    vim.notify("Usage: :BranchDiff <branch> [--two-dot|--reverse]", vim.log.levels.ERROR)
    return
  end

  local target = args[1]
  local two_dot = vim.tbl_contains(args, "--two-dot")
  local reverse = vim.tbl_contains(args, "--reverse")

  -- Get current branch
  local current = vim.fn.system("git branch --show-current"):gsub("%s+", "")
  if current == "" then
    vim.notify("Not on a branch", vim.log.levels.ERROR)
    return
  end

  local sep = two_dot and ".." or "..."
  local lhs, rhs = current, target

  if reverse then
    lhs, rhs = rhs, lhs
  end

  local spec = string.format("%s%s%s", lhs, sep, rhs)

  require("difft").diff(spec)
end, {
  nargs = "+",
  complete = "customlist,v:lua.GitBranchComplete",
})


return {
  "ahkohd/difft.nvim",
  config = function()
    require("difft").setup({
      command = "GIT_EXTERNAL_DIFF='difft --color=always' git diff",
      layout = "float", -- keeps context!
    })
  end,
}

