local function source_local_config()
  local arg = vim.fn.argv(0)
  local search_path = vim.fn.getcwd()

  if arg and arg ~= "" then
    local arg_path = vim.fn.fnamemodify(arg, ":p")
    local stat = vim.uv.fs_stat(arg_path)
    if stat and stat.type == "directory" then
      search_path = arg_path
    elseif stat and stat.type == "file" then
      search_path = vim.fs.dirname(arg_path)
    end
  end

  local matches = vim.fs.find(".nvim.lua", {
    upward = true,
    path = search_path,
    type = "file",
  })
  local path = matches[1]
  if not path then
    return
  end
  local read_path = vim.fn.fnamemodify(path, ":.")

  local ok_read, source = pcall(vim.secure.read, read_path)
  if not ok_read or not source then
    vim.notify("Local config not trusted: " .. path .. " (run :trust)", vim.log.levels.WARN)
    return
  end

  local chunk, load_err = load(source, "@" .. path)
  if not chunk then
    vim.notify("Failed to load " .. path .. ": " .. load_err, vim.log.levels.ERROR)
    return
  end

  local ok_run, run_err = pcall(chunk)
  if not ok_run then
    vim.notify("Failed to run " .. path .. ": " .. run_err, vim.log.levels.ERROR)
  end
end

source_local_config()
