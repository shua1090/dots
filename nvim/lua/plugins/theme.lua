return {
  "folke/tokyonight.nvim",
  lazy = false,      -- load at startup
  priority = 1000,   -- load before other UI plugins
  config = function()
    require("tokyonight").setup({
      style = "night", -- night | storm | moon | day
      transparent = false,
      terminal_colors = true,
    })

    local theme_names = {
      "tokyonight",
      "tokyonight-night",
      "tokyonight-storm",
      "tokyonight-moon",
      "catppuccin",
      "catppuccin-latte",
      "catppuccin-frappe",
      "catppuccin-macchiato",
      "catppuccin-mocha",
      "kanagawa",
      "kanagawa-wave",
      "kanagawa-dragon",
      "kanagawa-lotus",
      "nightfox",
      "dayfox",
      "dawnfox",
      "duskfox",
      "nordfox",
      "terafox",
      "carbonfox",
      "rose-pine",
      "rose-pine-main",
      "rose-pine-moon",
      "rose-pine-dawn",
      "onedark",
      "onedark_dark",
      "onedark_vivid",
      "onedark_darker",
    }

    local function apply_theme(name)
      local ok, err = pcall(vim.cmd.colorscheme, name)
      if not ok then
        vim.notify("Failed to set theme '" .. name .. "': " .. tostring(err), vim.log.levels.ERROR)
      end
    end

    if vim.fn.exists(":Theme") == 2 then
      vim.api.nvim_del_user_command("Theme")
    end
    vim.api.nvim_create_user_command("Theme", function(opts)
      local name = vim.trim(opts.args or "")
      if name == "" then
        vim.notify("Usage: :Theme <name>", vim.log.levels.INFO)
        return
      end
      apply_theme(name)
    end, {
      nargs = 1,
      complete = function(arglead)
        local matches = {}
        for _, name in ipairs(theme_names) do
          if vim.startswith(name, arglead) then
            table.insert(matches, name)
          end
        end
        return matches
      end,
      desc = "Switch colorscheme",
    })

    if vim.fn.exists(":ThemeList") == 2 then
      vim.api.nvim_del_user_command("ThemeList")
    end
    vim.api.nvim_create_user_command("ThemeList", function()
      vim.notify(table.concat(theme_names, "\n"), vim.log.levels.INFO, { title = "Available Themes" })
    end, {
      nargs = 0,
      desc = "List available colorschemes",
    })
  end,
}
