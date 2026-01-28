-- Open (or toggle) the chat buffer
vim.keymap.set("n", "<leader>cc", function()
  require("codecompanion").toggle({})
end, { desc = "Toggle CodeCompanion Chat (centered float)" })

vim.opt.splitright = true

-- Open action palette
vim.keymap.set("n", "<leader>ca", "<cmd>CodeCompanionActions<cr>", {
  desc = "CodeCompanion Action Palette",
})

require("codecompanion").setup({
  --   display = {
  -- chat = {
  --     window = {
  --         position = right
  --     }
  -- }},
    extensions = {
       spinner = {
         -- enabled = true, -- This is the default
         opts = {
           -- Your spinner configuration goes here
            style = "noice",
         },
       },
     },
  adapters = {
    acp = {
      opts = {
        show_presets = false,  -- only show your HTTP adapters
      },
      codex = function()
        return require("codecompanion.adapters").extend("codex", {
          defaults = {
            auth_method = "chatgpt", -- "openai-api-key"|"codex-api-key"|"chatgpt"
          },
        })
      end,
      gemini_cli = function()
        return require("codecompanion.adapters").extend("gemini_cli", {
          defaults = {
            auth_method = "oauth-personal", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
          },
        })
      end,
    },
    http = {
      opts = {
        show_presets = false,  -- only show your HTTP adapters
      },
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = {
            url = "http://dormammu:11434",
          },
          schema = {
            model = {
              default = "gpt-oss:120b",
            },
          },
        })
      end,
    },
  },
  interactions = {
    chat = {
      adapter = "ollama",
    },
    inline = {
      adapter = "ollama",
    },
    cmd = {
      adapter = "ollama",
    },
  },
})
