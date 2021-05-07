local M = {};
local fmt = string.format;
local _cfg = require'swift_env.config'.values;
local cfg = _cfg.format;
local Job = require'plenary.job';
local util = require'swift_env.util';
local strfun = util.strfun('swift_env.format');
local map = vim.api.nvim_set_keymap;
local cmd = vim.cmd;

M.create_and_format = function()
  local cwd = vim.loop.cwd();
  local path = fmt("%s/%s", cwd, cfg.config_file);
  local content = cfg.config_default_content;
  vim.fn.writefile(vim.split(content, "\n"), path)
  M.run()
end

M.run = function()
  local cwd = vim.loop.cwd();
  local ensure_cfile = cfg.config_create_if_unreadable;
  local cfile_path = fmt("%s/%s", cwd, cfg.config_file);
  local cfile_readable = util.filereadable(cfile_path);

  if ensure_cfile and not cfile_readable then
    return M.create_and_format()
  end

  local bufnr = vim.api.nvim_get_current_buf();
  local output = vim.fn.tempname();
  local args = {
    vim.api.nvim_buf_get_name(bufnr)
  };

  if cfile_readable then
    args[#args + 1] = "--config";
    args[#args + 1] = cfile_path;
  else
    args[#args + 1] = "--swfitversion"
    args[#args + 1] = "5.4"
  end

  args[#args + 1] = "--output";
  args[#args + 1] = output;

  local errout = {}
  local err = false
  --- TODO: do dryrun before attamping to format. If error, proceed to
  --formating
  Job:new({
    command = "swiftformat",
    args = args,
    on_exit = vim.schedule_wrap(function(j,c)
      if c ~= 0 then
        err = true
        errout = util.get_job_output(j)
      end
    end)
  }):sync()

  if util.not_empty(errout) and err then
    print("Error formating buffer")
  else
    util.set_buf_lines(bufnr, vim.fn.readfile(output))
  end
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
  cmd(fmt("command! %s lua %s]]", cfg.ex, main))
end

return M
