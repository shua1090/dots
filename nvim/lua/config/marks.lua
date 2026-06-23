local M = {}

local group = "UserMarks"
local sign_prefix = "UserMark_"
local sign_hl = "UserMarkSign"
local defined_signs = {}
local placed_marks = {}

local function is_real_buffer(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr)
    and vim.bo[bufnr].buftype == ""
    and vim.api.nvim_buf_line_count(bufnr) > 0
end

local function normalize_path(path)
  if not path or path == "" then
    return nil
  end

  return vim.fn.fnamemodify(path, ":p")
end

local function mark_belongs_to_buffer(mark, bufnr, bufname)
  local pos = mark.pos or {}

  if pos[1] == bufnr then
    return true
  end

  local mark_file = normalize_path(mark.file)
  return mark_file ~= nil and mark_file == bufname
end

local function add_mark(results, seen, mark, bufnr, bufname, line_count)
  local mark_name = mark.mark or ""
  local mark_char = mark_name:sub(2, 2)
  local lnum = tonumber((mark.pos or {})[2]) or 0

  if not mark_char:match("%a") or lnum < 1 or lnum > line_count then
    return
  end

  if seen[mark_char] or not mark_belongs_to_buffer(mark, bufnr, bufname) then
    return
  end

  seen[mark_char] = true
  table.insert(results, { char = mark_char, lnum = lnum })
end

local function get_marks(bufnr)
  local marks = {}
  local seen = {}
  local bufname = normalize_path(vim.api.nvim_buf_get_name(bufnr))
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  for _, mark in ipairs(vim.fn.getmarklist(bufnr)) do
    add_mark(marks, seen, mark, bufnr, bufname, line_count)
  end

  for _, mark in ipairs(vim.fn.getmarklist()) do
    add_mark(marks, seen, mark, bufnr, bufname, line_count)
  end

  table.sort(marks, function(left, right)
    if left.lnum == right.lnum then
      return left.char < right.char
    end

    return left.lnum < right.lnum
  end)

  return marks
end

local function sign_name(mark_char)
  local name = sign_prefix .. mark_char

  if not defined_signs[name] then
    vim.fn.sign_define(name, {
      text = mark_char,
      texthl = sign_hl,
      numhl = "",
    })
    defined_signs[name] = true
  end

  return name
end

local function marks_signature(marks)
  local parts = {}

  for _, mark in ipairs(marks) do
    table.insert(parts, mark.char .. ":" .. mark.lnum)
  end

  return table.concat(parts, "|")
end

function M.refresh(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not is_real_buffer(bufnr) then
    return
  end

  local marks = get_marks(bufnr)
  local signature = marks_signature(marks)
  if placed_marks[bufnr] == signature then
    return
  end

  placed_marks[bufnr] = signature
  vim.fn.sign_unplace(group, { buffer = bufnr })

  for _, mark in ipairs(marks) do
    vim.fn.sign_place(0, group, sign_name(mark.char), bufnr, {
      lnum = mark.lnum,
      priority = 8,
    })
  end
end

function M.setup()
  vim.cmd("highlight default link " .. sign_hl .. " DiagnosticHint")

  local augroup = vim.api.nvim_create_augroup("UserMarkSigns", { clear = true })
  vim.api.nvim_create_autocmd({
    "BufEnter",
    "BufWritePost",
    "CursorHold",
    "FocusGained",
    "TextChanged",
    "TextChangedI",
  }, {
    group = augroup,
    callback = function(event)
      M.refresh(event.buf)
    end,
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = augroup,
    pattern = ":",
    callback = function()
      M.refresh()
    end,
  })

  vim.api.nvim_create_autocmd("SafeState", {
    group = augroup,
    callback = function()
      M.refresh()
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = augroup,
    callback = function(event)
      placed_marks[event.buf] = nil
    end,
  })

  vim.keymap.set("n", "m", function()
    local ok, key = pcall(vim.fn.getcharstr)
    if not ok or key == "" or key == "\027" then
      return
    end

    local set_ok = pcall(vim.cmd.normal, { bang = true, args = { "m" .. key } })
    if set_ok then
      M.refresh()
    end
  end, { desc = "Set mark", silent = true })

  M.refresh()
end

return M
