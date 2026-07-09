-- lua/plugins/buffer-sticks.lua
return {
  "ahkohd/buffer-sticks.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>j",
      function()
        require("buffer-sticks").jump()
      end,
      desc = "Jump to buffer",
    },
  },
  config = function()
    local sticks = require("buffer-sticks")
    local create_autocmd = vim.api.nvim_create_autocmd
    vim.api.nvim_create_autocmd = function(events, opts)
      if type(events) == "table" then
        events = vim.tbl_filter(function(event)
          return event ~= "BufModifiedSet"
        end, events)
      elseif events == "BufModifiedSet" then
        return 0
      end
      return create_autocmd(events, opts)
    end

    local ok, err = pcall(sticks.setup, {
      -- close the UI as soon as a buffer is selected
      close_on_select = true,
      highlight_current = true,
    })

    vim.api.nvim_create_autocmd = create_autocmd
    if not ok then
      error(err)
    end
  end,
}
