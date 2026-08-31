local function capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()
  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink then
    caps = blink.get_lsp_capabilities(caps)
  end
  return caps
end

return {
  {
    "saecki/crates.nvim",
    ft = { "toml" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      completion = {
        blink = {
          enabled = true,
        },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
    keys = {
      {
        "<leader>lc",
        function()
          require("crates").show_popup()
        end,
        ft = "toml",
        desc = "Crates: show crate",
      },
      {
        "<leader>lU",
        function()
          require("crates").upgrade_crate()
        end,
        ft = "toml",
        desc = "Crates: upgrade crate",
      },
    },
  },
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {
      inlay_hints = {
        inline = true,
      },
      ast = {
        role_icons = {
          type = "",
          declaration = "",
          expression = "",
          specifier = "",
          statement = "",
          ["template argument"] = "",
        },
      },
    },
    config = function(_, opts)
      require("clangd_extensions").setup(opts)
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          local root = vim.fs.root(0, {
            "gradlew",
            "mvnw",
            ".git",
            "pom.xml",
            "build.gradle",
            "settings.gradle",
          })
          if not root then
            return
          end

          local cmd = vim.fn.exepath("jdtls")
          if cmd == "" then
            cmd = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
          end
          if vim.fn.executable(cmd) ~= 1 then
            vim.notify("jdtls executable not found", vim.log.levels.WARN)
            return
          end

          local workspace = vim.fn.stdpath("data")
            .. "/jdtls-workspaces/"
            .. vim.fn.fnamemodify(root, ":p:h:t")

          require("jdtls").start_or_attach({
            cmd = { cmd, "-data", workspace },
            root_dir = root,
            capabilities = capabilities(),
          })
        end,
      })
    end,
  },
}
