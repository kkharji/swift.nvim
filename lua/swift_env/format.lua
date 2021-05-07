local M = {};
local fmt = string.format;
local _cfg = require'swift_env.config'.values;
local cfg = _cfg.format;
local Job = require'plenary.job';
local util = require'swift_env.util';
local strfun = util.strfun('swift_env.format');
local map = vim.api.nvim_set_keymap;
local cmd = vim.cmd;
local log = util.log;

M.create_and_format = function()
  local cwd = vim.loop.cwd();
  local path = fmt("%s/%s", cwd, cfg.config_file);
  local content = cfg.config_default_content;
  vim.fn.writefile(vim.split(content, "\n"), path)
  M.run()
end

M.run = function()
  local cwd = vim.loop.cwd();
  local check = cfg.config_create_if_unreadable;
  local cfile_path = fmt("%s/%s", cwd, cfg.config_file);
  local exists = util.filereadable(cfile_path);

  if check and not exists then return M.create_and_format() end

  local bufnr = vim.api.nvim_get_current_buf();
  local buflines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local args = {
    "stdin",
    "--stdinpath",
    vim.api.nvim_buf_get_name(0),
  }

  if exists then
    args[#args + 1] = "--config";
    args[#args + 1] = cfile_path;
  else
    args[#args + 1] = "--swfitversion";
    args[#args + 1] = "5.4";
  end

  local err = false;

  local fmt = Job:new({
    writer = table.concat(buflines, "\n"),
    command = "swiftformat",
    args = args,
    on_exit = vim.schedule_wrap(function(j,_)
      --- swiftformat return non-0 and that seems the only way to check for errors
      local stderr = j:stderr_result();
      if stderr[3] ~= "Swiftformat completed successfully." then
        err = true;
        log.error(fmt("Unexpcted error while formating", table.concat(stderr, "\n")))
      else
        err = false
      end
    end)
  })

  fmt:sync();

  local new = fmt:result();

  --- TODO: use log.
  if util.not_empty(new) and err then
    return print("Error formating buffer");
  end

  util.set_buf_lines(bufnr, new)
end


-- Main Attach function for swift env
M.attach = function()
  local main = strfun('run()')
  -- setup autocmd
  if cfg.auto then
    cmd(fmt("autocmd BufWritePre <buffer> :lua %s", main))
  end
  -- setup mapping
  map('n', _cfg.leader .. cfg.mapping, fmt(":lua %s<cr>", main), { noremap = true })
  -- setup command
  cmd(fmt("command! %s lua %s", cfg.ex, main))
end

return M
