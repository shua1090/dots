require("triforce").setup({
  notifications = {
    enabled = false,
    level_up = false,
    achievements = false,
  },
  keymap = {
    show_profile = "<leader>u",
  },
})

local profile_ok, profile = pcall(require, "triforce.ui.profile")
if profile_ok then
  local function target_size()
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    return width, height
  end

  local function clamp_profile_window()
    local float = profile.dimensions.float
    if not (float and float.win and vim.api.nvim_win_is_valid(float.win)) then
      return
    end

    local target_w, target_h = target_size()
    local max_w = math.max(1, vim.o.columns - 4)
    local max_h = math.max(1, vim.o.lines - 4)
    local new_w = math.min(target_w, max_w)

    local current = vim.api.nvim_win_get_config(float.win)
    if not current.relative or current.relative == "" then
      return
    end

    local current_h = current.height or profile.dimensions.height or target_h
    local new_h = math.min(math.max(current_h, target_h), max_h)

    profile.dimensions.width = new_w
    profile.dimensions.height = new_h

    local updated = vim.tbl_extend("force", current, {
      row = math.floor((vim.o.lines - new_h) / 2),
      col = math.floor((vim.o.columns - new_w) / 2),
      width = new_w,
      height = new_h,
    })
    vim.api.nvim_win_set_config(float.win, updated)
  end

  if not profile.__codex_patched then
    local orig_open = profile.open
    profile.open = function(...)
      local target_w, target_h = target_size()
      profile.dimensions.width = target_w
      profile.dimensions.height = target_h
      orig_open(...)
      clamp_profile_window()
    end

    local orig_redraw = profile.redraw
    profile.redraw = function(...)
      orig_redraw(...)
      clamp_profile_window()
    end

    profile.close = function()
      local dims = profile.dimensions
      if not dims then
        return
      end

      local float = dims.float
      local dim_float = dims.dim_float
      if float and float.win then
        pcall(vim.api.nvim_win_close, float.win, true)
      end
      if dim_float and dim_float.win then
        pcall(vim.api.nvim_win_close, dim_float.win, true)
      end
      if float and float.buf then
        pcall(vim.api.nvim_buf_delete, float.buf, { force = true })
      end
      if dim_float and dim_float.buf then
        pcall(vim.api.nvim_buf_delete, dim_float.buf, { force = true })
      end

      dims.float = nil
      dims.dim_float = nil
    end

    profile.__codex_patched = true
  end

  local group = vim.api.nvim_create_augroup("TriforceProfileSize", { clear = true })
  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      local target_w, target_h = target_size()
      profile.dimensions.width = target_w
      profile.dimensions.height = target_h
      clamp_profile_window()
    end,
  })
end
