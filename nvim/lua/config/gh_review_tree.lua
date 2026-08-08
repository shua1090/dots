local M = {}

local ns = vim.api.nvim_create_namespace("user_gh_review_tree")
local collapsed = {}

local function change_type_to_flag(change_type)
  if change_type == "ADDED" then return "A" end
  if change_type == "DELETED" then return "D" end
  if change_type == "RENAMED" then return "R" end
  if change_type == "COPIED" then return "C" end
  return "M"
end

local function path_parts(path)
  local parts = {}
  for part in path:gmatch("[^/]+") do
    parts[#parts + 1] = part
  end
  return parts
end

local function sorted_keys(t)
  local keys = vim.tbl_keys(t)
  table.sort(keys, function(a, b)
    return a:lower() < b:lower()
  end)
  return keys
end

local function build_file_tree(files)
  local state = require("gh_review.state")
  local root = { path = "", dirs = {}, files = {}, additions = 0, deletions = 0, count = 0 }

  for _, file in ipairs(files) do
    local path = state.get(file, "path", "")
    local parts = path_parts(path)
    local additions = state.get(file, "additions", 0)
    local deletions = state.get(file, "deletions", 0)
    local node = root

    node.additions = node.additions + additions
    node.deletions = node.deletions + deletions
    node.count = node.count + 1

    for i = 1, math.max(#parts - 1, 0) do
      local dirname = parts[i]
      local dirpath = node.path == "" and dirname or (node.path .. "/" .. dirname)
      node.dirs[dirname] = node.dirs[dirname] or {
        path = dirpath,
        dirs = {},
        files = {},
        additions = 0,
        deletions = 0,
        count = 0,
      }
      node = node.dirs[dirname]
      node.additions = node.additions + additions
      node.deletions = node.deletions + deletions
      node.count = node.count + 1
    end

    node.files[parts[#parts] or path] = file
  end

  return root
end

local function file_icon(filename)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return "", "Normal"
  end

  local icon, hl = devicons.get_icon(filename, nil, { default = true })
  return icon or "", hl or "Normal"
end

local function set_line_stat(bufnr, row, text, hl)
  vim.api.nvim_buf_set_extmark(bufnr, ns, row - 1, 0, {
    virt_text = { { text, hl or "Comment" } },
    virt_text_pos = "right_align",
    hl_mode = "combine",
  })
end

local function directory_stat(node)
  return string.format("+%d -%d  (%d)", node.additions, node.deletions, node.count)
end

local function file_stat(file)
  local state = require("gh_review.state")
  local path = state.get(file, "path", "")
  local additions = state.get(file, "additions", 0)
  local deletions = state.get(file, "deletions", 0)
  local threads = state.get_threads_for_file(path)
  local suffix = #threads > 0 and string.format("  [%d thread%s]", #threads, #threads > 1 and "s" or "") or ""
  return string.format("+%d -%d%s", additions, deletions, suffix)
end

local function flag_highlight(flag)
  return ({
    A = "ghReviewFlagA",
    D = "ghReviewFlagD",
    M = "ghReviewFlagM",
    R = "ghReviewFlagR",
    C = "ghReviewFlagC",
  })[flag] or "Comment"
end

function M.render()
  local state = require("gh_review.state")
  local bufnr = state.get_files_bufnr()
  if bufnr == -1 or vim.fn.bufexists(bufnr) == 0 then
    return
  end

  local files = state.get_changed_files()
  local old_entries = vim.b[bufnr].gh_review_entry_by_line or {}
  local winid = vim.fn.bufwinid(bufnr)
  local old_key
  if winid ~= -1 then
    local cursor = vim.api.nvim_win_get_cursor(winid)
    local old_entry = old_entries[cursor[1]]
    old_key = old_entry and (old_entry.path or old_entry.name)
  end

  local lines = {}
  local entries = {}
  local file_by_line = {}
  local path_to_line = {}
  local highlights = {}
  local stats = {}
  local pr_url = string.format("https://github.com/%s/%s/pull/%d", state.get_owner(), state.get_name(), state.get_pr_number())

  lines[#lines + 1] = string.format("%s: %s", pr_url, state.get_pr_title())
  lines[#lines + 1] = string.format("Files changed (%d)", #files)
  lines[#lines + 1] = ""

  local function add_line(line, entry, stat, stat_hl)
    lines[#lines + 1] = line
    if entry then
      entries[#lines] = entry
      if entry.type == "file" then
        file_by_line[#lines] = entry.file
      end
      path_to_line[entry.path or entry.name] = #lines
    end
    if stat then
      stats[#lines] = { text = stat, hl = stat_hl }
    end
    return #lines
  end

  local function render_node(node, depth)
    local indent = string.rep("  ", depth)

    for _, dirname in ipairs(sorted_keys(node.dirs)) do
      local child = node.dirs[dirname]
      local is_collapsed = collapsed[child.path] == true
      local expander = is_collapsed and "" or ""
      local folder = is_collapsed and "" or ""
      local row = add_line(
        string.format("%s%s %s %s/", indent, expander, folder, dirname),
        { type = "directory", path = child.path, name = dirname },
        directory_stat(child),
        "Comment"
      )
      highlights[#highlights + 1] = { row = row, col_start = #indent + 3, col_end = #indent + 6, hl = "Directory" }

      if not is_collapsed then
        render_node(child, depth + 1)
      end
    end

    for _, filename in ipairs(sorted_keys(node.files)) do
      local file = node.files[filename]
      local path = state.get(file, "path", "")
      local flag = change_type_to_flag(state.get(file, "changeType", "MODIFIED"))
      local checkbox = state.is_file_checked(path) and "[x]" or "[ ]"
      local icon, icon_hl = file_icon(filename)
      local row = add_line(
        string.format("%s  %s %s %s %s", indent, checkbox, flag, icon, filename),
        { type = "file", path = path, name = filename, file = file },
        file_stat(file),
        "Comment"
      )
      local flag_col = #indent + 6
      local icon_col = flag_col + 2
      highlights[#highlights + 1] = { row = row, col_start = flag_col, col_end = flag_col + 1, hl = flag_highlight(flag) }
      highlights[#highlights + 1] = { row = row, col_start = icon_col, col_end = icon_col + #icon, hl = icon_hl }
    end
  end

  render_node(build_file_tree(files), 0)

  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.b[bufnr].gh_review_entry_by_line = entries
  vim.b[bufnr].gh_review_file_by_line = file_by_line

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  for row, stat in pairs(stats) do
    set_line_stat(bufnr, row, " " .. stat.text, stat.hl)
  end
  for _, item in ipairs(highlights) do
    vim.api.nvim_buf_set_extmark(bufnr, ns, item.row - 1, item.col_start, {
      end_col = item.col_end,
      hl_group = item.hl,
      hl_mode = "combine",
    })
  end

  if winid ~= -1 then
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local row = old_key and path_to_line[old_key] or vim.api.nvim_win_get_cursor(winid)[1]
    row = math.max(math.min(row or 4, line_count), math.min(4, line_count))
    vim.api.nvim_win_set_cursor(winid, { row, 0 })
  end
end

function M.entry_under_cursor(bufnr, lnum)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  lnum = lnum or vim.fn.line(".")
  return (vim.b[bufnr].gh_review_entry_by_line or {})[lnum]
end

function M.file_under_cursor(bufnr, lnum)
  local entry = M.entry_under_cursor(bufnr, lnum)
  return entry and entry.file or nil
end

function M.toggle_directory_under_cursor()
  local entry = M.entry_under_cursor()
  if not entry or entry.type ~= "directory" then
    return false
  end

  collapsed[entry.path] = not collapsed[entry.path]
  M.render()
  return true
end

function M.expand_or_open_under_cursor(open_file)
  local entry = M.entry_under_cursor()
  if entry and entry.type == "directory" then
    collapsed[entry.path] = false
    M.render()
    return true
  end

  if open_file then
    open_file()
    return true
  end

  return false
end

function M.collapse_under_cursor()
  local entry = M.entry_under_cursor()
  if not entry or entry.type ~= "directory" then
    return false
  end

  collapsed[entry.path] = true
  M.render()
  return true
end

function M.toggle_checked_under_cursor()
  if M.toggle_directory_under_cursor() then
    return
  end

  local file = M.file_under_cursor()
  if not file or not file.path then return end

  local state = require("gh_review.state")
  local path = file.path
  local checked = not state.is_file_checked(path)
  state.set_file_checked(path, checked)
  M.render()

  local api = require("gh_review.api")
  local graphql = require("gh_review.graphql")
  local mutation = checked and graphql.MUTATION_MARK_FILE_VIEWED or graphql.MUTATION_UNMARK_FILE_VIEWED
  api.graphql(mutation, { pullRequestId = state.get_pr_id(), path = path }, function(result, err)
    local data = ((result or {}).data) or {}
    local ok = not err and (data.markFileAsViewed or data.unmarkFileAsViewed)
    if not ok and state.is_file_checked(path) == checked then
      state.set_file_checked(path, not checked)
      M.render()
    end
  end)
end

function M.patch_plugin()
  local files = require("gh_review.files")
  if files._user_hierarchical_renderer_patched then
    return
  end

  local function rerender_after(fn)
    return function(...)
      local result = { fn(...) }
      vim.schedule(M.render)
      return unpack(result)
    end
  end

  files.open = rerender_after(files.open)
  files.rerender = rerender_after(files.rerender)

  local toggle = files.toggle
  files.toggle = function(...)
    local result = { toggle(...) }
    local state = require("gh_review.state")
    if state.get_files_bufnr() ~= -1 and vim.fn.bufwinid(state.get_files_bufnr()) ~= -1 then
      vim.schedule(M.render)
    end
    return unpack(result)
  end

  files._user_hierarchical_renderer_patched = true
end

return M
