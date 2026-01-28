require("project_nvim").setup({
  manual_mode = true,

  detection_methods = { "pattern" },

  patterns = {
    ".git",
    "Makefile",
    "package.json",
    "Cargo.toml",
    "pyproject.toml",
    "go.mod",
  },

  -- Make project root the global cwd
  scope_chdir = "global",

  silent_chdir = false,
})

