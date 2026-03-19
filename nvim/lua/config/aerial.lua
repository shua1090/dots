local aerial = require("aerial")

local M = {}

local ignored_filetypes = {
  ["aerial"] = true,
  ["alpha"] = true,
  ["checkhealth"] = true,
  ["lazy"] = true,
  ["mason"] = true,
  ["neo-tree"] = true,
  ["noice"] = true,
  ["TelescopePrompt"] = true,
}

local function filename_for(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return "[No Name]"
  end
  return vim.fn.fnamemodify(name, ":t")
end

function M.winbar()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype ~= "" then
    return ""
  end

  if ignored_filetypes[vim.bo[bufnr].filetype] then
    return ""
  end

  local parts = { filename_for(bufnr) }
  local ok, symbols = pcall(aerial.get_location, false)
  if ok and symbols and #symbols > 0 then
    local first = math.max(1, #symbols - 2)
    for i = first, #symbols do
      local item = symbols[i]
      if item and item.name and item.name ~= "" then
        parts[#parts + 1] = item.name
      end
    end
  end

  return " " .. table.concat(parts, " > ") .. " "
end

aerial.setup({
  backends = { "lsp", "treesitter", "markdown" },
  layout = {
    min_width = 24,
    max_width = 48,
  },
  filter_kind = false,
  show_guides = true,
})

vim.o.winbar = "%{%v:lua.require'config.aerial'.winbar()%}"
vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle<cr>", { desc = "Outline (aerial)" })

return M
