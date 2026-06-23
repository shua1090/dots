local function source_local_config()
  local matches = vim.fs.find(".nvim.lua", {
    upward = true,
    path = vim.fn.getcwd(),
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
