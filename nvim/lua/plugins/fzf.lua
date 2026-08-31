local root_patterns = {
  ".git",
  "Makefile",
  "package.json",
  "Cargo.toml",
  "pyproject.toml",
  "go.mod",
  "pom.xml",
  "build.gradle",
  "settings.gradle",
}

local function cwd()
  return vim.uv.cwd() or vim.fn.getcwd()
end

local function root()
  local bufname = vim.api.nvim_buf_get_name(0)
  local start = bufname ~= "" and bufname or cwd()
  return vim.fs.root(start, root_patterns) or cwd()
end

local function is_git_repo(dir)
  vim.fn.system({ "git", "-C", dir, "rev-parse", "--is-inside-work-tree" })
  return vim.v.shell_error == 0
end

local function files(opts)
  opts = opts or {}
  local dir = opts.cwd or root()
  local fzf = require("fzf-lua")
  if is_git_repo(dir) then
    fzf.git_files({
      cwd = dir,
      cmd = "git ls-files --exclude-standard --cached --others",
      prompt = "Files> ",
    })
  else
    fzf.files({
      cwd = dir,
      prompt = "Files> ",
    })
  end
end

local function live_grep(opts)
  require("fzf-lua").live_grep({
    cwd = opts and opts.cwd or root(),
    prompt = "Grep> ",
  })
end

local function project_picker()
  local ok, project = pcall(require, "project_nvim")
  local projects = ok and project.get_recent_projects and project.get_recent_projects() or {}
  if #projects == 0 then
    vim.notify("No recent projects yet", vim.log.levels.INFO)
    return
  end

  require("fzf-lua").fzf_exec(projects, {
    prompt = "Projects> ",
    actions = {
      ["default"] = function(selected)
        local dir = selected and selected[1]
        if not dir or dir == "" then
          return
        end
        require("project_nvim.project").set_pwd(dir, "manual")
        files({ cwd = dir })
      end,
    },
  })
end

return {
  "ibhagwan/fzf-lua",
  cmd = "FzfLua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<C-f>", "<cmd>FzfLua blines<cr>", desc = "Find in buffer" },
    { "<leader>ff", files, desc = "Find files (root)" },
    {
      "<leader>fF",
      function()
        files({ cwd = cwd() })
      end,
      desc = "Find files (cwd)",
    },
    { "<leader>fg", live_grep, desc = "Live grep (root)" },
    {
      "<leader>fG",
      function()
        live_grep({ cwd = cwd() })
      end,
      desc = "Live grep (cwd)",
    },
    { "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help" },
    { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
    { "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
    { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Find symbols (current file)" },
    { "<leader>fS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Find symbols (workspace)" },
    { "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Buffer diagnostics" },
    { "<leader>fD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace diagnostics" },
    { "<leader>pp", project_picker, desc = "Pick project" },
  },
  opts = function()
    local fzf = require("fzf-lua")
    local actions = fzf.actions
    local config = fzf.config

    config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
    config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
    config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
    config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
    config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
    config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
    config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

    local ok_trouble, trouble = pcall(require, "trouble.sources.fzf")
    if ok_trouble then
      config.defaults.actions.files["ctrl-t"] = trouble.actions.open
    end

    return {
      "default-title",
      fzf_colors = true,
      fzf_opts = {
        ["--no-scrollbar"] = true,
      },
      defaults = {
        formatter = "path.dirname_first",
        git_icons = true,
        file_icons = true,
      },
      winopts = {
        width = 0.82,
        height = 0.82,
        row = 0.5,
        col = 0.5,
        border = "rounded",
        preview = {
          border = "border",
          scrollchars = { "┃", "" },
        },
      },
      files = {
        cwd_prompt = false,
        fd_opts = "--color=never --type f --hidden --follow --exclude .git",
        rg_opts = "--color=never --files --hidden --follow -g !.git",
        actions = {
          ["f10"] = { actions.toggle_hidden },
          ["f11"] = { actions.toggle_ignore },
        },
      },
      grep = {
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --glob !.git/",
        actions = {
          ["f10"] = { actions.toggle_hidden },
          ["f11"] = { actions.toggle_ignore },
        },
      },
      lsp = {
        code_actions = {
          previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
        },
        symbols = {
          child_prefix = false,
        },
      },
      ui_select = function(fzf_opts, items)
        return vim.tbl_deep_extend("force", fzf_opts, {
          prompt = "Select> ",
          winopts = {
            title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
            title_pos = "center",
            width = 0.5,
            height = math.floor(math.min(vim.o.lines * 0.8, #items + 4) + 0.5),
          },
        })
      end,
    }
  end,
  config = function(_, opts)
    if opts[1] == "default-title" then
      local function fix(t)
        t.prompt = t.prompt ~= nil and " " or nil
        for _, value in pairs(t) do
          if type(value) == "table" then
            fix(value)
          end
        end
        return t
      end
      opts = vim.tbl_deep_extend("force", fix(require("fzf-lua.profiles.default-title")), opts)
      opts[1] = nil
    end

    require("fzf-lua").setup(opts)
  end,
}
