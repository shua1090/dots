require("project_nvim").setup({
  manual_mode = false,

  detection_methods = { "pattern" },

  patterns = {
    ".git",
    "Makefile",
    "package.json",
    "Cargo.toml",
    "pyproject.toml",
    "go.mod",
    "README.md",
  },

  -- Make project root the global cwd
  scope_chdir = "global",

  silent_chdir = true,
})


