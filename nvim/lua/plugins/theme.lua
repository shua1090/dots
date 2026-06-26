return {
  "navarasu/onedark.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("onedark").setup({
      style = "deep",
    })

    local styles = {
      "deep",
      "dark",
      "darker",
      "cool",
      "warm",
      "warmer",
      "light",
    }

    vim.api.nvim_create_user_command("Theme", function(opts)
      local name = vim.trim(opts.args or "")
      if name == "" then
        vim.notify("Usage: :Theme " .. table.concat(styles, " | "), vim.log.levels.INFO)
        return
      end

      local ok, err = pcall(function()
        require("onedark").setup({ style = name })
        vim.cmd.colorscheme("onedark")
      end)
      if not ok then
        vim.notify("Failed to set theme '" .. name .. "': " .. tostring(err), vim.log.levels.ERROR)
      end
    end, {
      nargs = 1,
      complete = function(arglead)
        local matches = {}
        for _, name in ipairs(styles) do
          if vim.startswith(name, arglead) then
            table.insert(matches, name)
          end
        end
        return matches
      end,
      desc = "Switch colorscheme style",
    })
  end,
}
