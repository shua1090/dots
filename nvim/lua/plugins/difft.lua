vim.api.nvim_create_user_command("BranchDiff", function(opts)
  local target = opts.fargs[1]
  if not target then
    vim.notify("Usage: :BranchDiff <branch>", vim.log.levels.ERROR)
    return
  end

  local current = vim.fn.system("git branch --show-current"):gsub("%s+", "")
  if current == "" then
    vim.notify("Detached HEAD", vim.log.levels.ERROR)
    return
  end

  require("difft").diff(string.format("%s...%s", target, current))
end, {
  nargs = 1,
  complete = "customlist,v:lua.GitBranchComplete",
})

return {
  "ahkohd/difft.nvim",
  config = function()
    require("difft").setup({
      command = table.concat({
        "GIT_EXTERNAL_DIFF='difft",
        "--color=always",
        "--display side-by-side",
        "' git diff",
      }, " "),
    })
  end,
}
