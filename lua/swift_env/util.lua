local fmt = string.format
local util = {}

---Creates lua string function call. used for mappings and autocmds
---@param mname string: the module name
---@return function: accept the fname and return a lua require ...
util.strfun = function (mname)
  return function (fname)
    return fmt("require'%s'.%s", mname, fname)
  end
end

--- Check if a given variable is empty. covers lists, tables, strings and check
--- if the variable is nil.
---@param xs any
---@return boolean
util.is_empty = function(xs)
  if type(xs) == "string" then
    return xs == ''
  elseif type(xs) == "table" then
    return vim.tbl_isempty(xs)
  elseif xs == nil then
    return true
  end
end

---Same as |is_empty| except it return true if the given variable is not empty.
---@param xs any
---@return boolean
util.not_empty = function(xs)
  return not util.is_empty(xs)
end

---Return true if file exists.
util.filereadable = function(path)
  return vim.loop.fs_lstat(path) ~= nil
end

---Return true if filename in current dirctory exists.
util.filereadable_cwd = function(filename)
  return util.file_exists(vim.loop.cwd() .. "/" .. filename)
end

---Write content to file.
util.write_async = function(path, content, cb)
  content = type(content) == "table" and table.concat(content, "\n") or content
  content = content .. "\n"
  return vim.loop.fs_open(path, "a", 438, function(err, fd)
    assert(not err, err)
    vim.loop.fs_write(fd, content, -1, function(_err, _)
      assert(not _err, err)
      vim.loop.fs_close(fd, function(__err)
        assert(not __err, err)
        return cb and cb(path) or nil
      end)
    end)
  end)
end

util.get_job_output = function(j)
  local out = j:result()
  local err = j:stderr_result()
  return vim.tbl_isempty(out) and err or out
end

util.get_buf_info = function()
  local pos = vim.fn.winsaveview()
  local winnr = vim.fn.winnr()
  return winnr, pos
end

util.set_buf_lines = function(bufnr, content)
  if type(content) == "string" then
    content = vim.split(content, "\n")
  end

  local _, pos = util.get_buf_info()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
  vim.fn.winrestview(pos)
end

util.readfile = function(path, callback)
  vim.loop.fs_open(path, "r", 438, function(err, fd)
    assert(not err, err)
    vim.loop.fs_fstat(fd, function(err, stat)
      assert(not err, err)
      vim.loop.fs_read(fd, stat.size, 0, function(err, data)
        assert(not err, err)
        vim.loop.fs_close(fd, function(err)
          assert(not err, err)
          return callback(data)
        end)
      end)
    end)
  end)
end

return util

