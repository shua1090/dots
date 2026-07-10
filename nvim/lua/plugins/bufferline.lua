local function close_buffer(bufnr)
  local ok_snacks, snacks = pcall(require, "snacks")
  if ok_snacks and snacks.bufdelete then
    snacks.bufdelete(bufnr)
    return
  end
  vim.cmd("bdelete " .. bufnr)
end

return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>tt", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
    {
      "<leader>tq",
      function()
        close_buffer(vim.api.nvim_get_current_buf())
      end,
      desc = "Close buffer",
    },
    { "<leader>tn", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<leader>tN", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
    { "<leader>tp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle buffer pin" },
    { "<leader>tr", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers right" },
    { "<leader>tl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffers left" },
    { "<leader>to", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Close unpinned buffers" },
    { "<C-Tab>", "<cmd>BufferLineCycleNext<cr>", mode = { "n", "i", "t" }, desc = "Next buffer" },
    { "<C-S-Tab>", "<cmd>BufferLineCyclePrev<cr>", mode = { "n", "i", "t" }, desc = "Previous buffer" },
    { "<C-ISO_Left_Tab>", "<cmd>BufferLineCyclePrev<cr>", mode = { "n", "i", "t" }, desc = "Previous buffer" },
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
    { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
  },
  opts = {
    options = {
      mode = "buffers",
      close_command = close_buffer,
      right_mouse_command = close_buffer,
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      separator_style = "thin",
      show_buffer_close_icons = false,
      show_close_icon = false,
      sort_by = "insert_after_current",
      diagnostics_indicator = function(_, _, diagnostics)
        local result = {}
        if diagnostics.error then
          table.insert(result, " " .. diagnostics.error)
        end
        if diagnostics.warning then
          table.insert(result, " " .. diagnostics.warning)
        end
        return table.concat(result, " ")
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Explorer",
          highlight = "Directory",
          text_align = "left",
        },
      },
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
      callback = function()
        vim.schedule(function()
          pcall(vim.cmd, "redrawtabline")
        end)
      end,
    })
  end,
}
