require("avante").setup({
    provider = "ollama",
    auto_suggestions_provider = "ollama_fast",
    behaviour = {
        auto_suggestions = false,
    },
    suggestion = {
        debounce = 500,
        throttle = 500,
    },
    providers = {
        ollama = {
            endpoint = "http://dormammu:11434",
            model = "gpt-oss:120b",
            is_env_set = function()
                return true
            end,
        },
        ollama_fast = {
            __inherited_from = "ollama",
            model = "llama3.2:3b",
        },
    },
})
