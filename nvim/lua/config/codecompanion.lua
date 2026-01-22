require("codecompanion").setup({
  adapters = {
    acp = {
      codex = function()
        return require("codecompanion.adapters").extend("codex", {
          defaults = {
            auth_method = "chatgpt", -- "openai-api-key"|"codex-api-key"|"chatgpt"
          },
        })
      end,
    },
    http = {
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
