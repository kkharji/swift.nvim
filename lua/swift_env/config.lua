local config = {}
local log = require'plenary.log'.new({ plugin = 'swift.nvim' })

_SwiftEnvConfig = _SwiftEnvConfig or {}

config.values = _SwiftEnvConfig

local defaults = {
  --- debug mode
  debug = true,
  --- Normal/Visual Mode leader key
  leader = "<leader>",
  --- Format Configuration
  format = {
    -- path to the swiftformat binary.
    cmd = "swiftformat",
    -- command to run formater manually
    ex = "Sfmt",
    -- mapping to run formater manually
    mapping = "eF",
    -- whether to format on write.
    auto = true,
    -- options to be passed when calling swiftformat from the command line
    options = {},
    -- path to config file from root directory
    config_file = ".swiftformat",
    -- create config format config file when it doesn't exists?
    config_create_if_unreadable = true,
    -- The content of the format configuration file.
    config_default_content = [[
# see avaliable rules: https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md

# Format Options

--empty void
--swiftversion 5.4
--indent 2
--indentcase true
--semicolons inline
--shortoptionals always
--stripunusedargs always
--wrapcollections before-first
--wraparguments before-first
--header "{file}\nCopyright (c) {year} Foobar Industries\nCreated by Tami on {created}."
--tabwidth 2
--self remove

# Rules

--disable linebreakAtEndOfFile
--disable preferKeyPath
--enable redundantParens
--enable redundantLet
--enable redundantNilInit
--disable redundantPattern
--enable redundantReturn
    ]]
  }
}

--- Enahnced version of builtin type function that inclued list type.
---@param val any
---@return string
local get_type = function(val)
  local typ = type(val)
  if val == "table" then
    return vim.tbl_islist(val) and "list" or "table"
  else
    return typ
  end
end

--- returns true if the key name should be skipped when doing type checking.
---@param key string
---@return boolean: true if it should be if key skipped
local should_skip_type_checking = function(key)
  for _, v in ipairs({ 'options' }) do
    for _, k in ipairs(vim.split(key, "%.")) do
      if k:find(v) then
        return true
      end
    end
  end
  return false
end


--- Checks defaults values types against modification values.
--- skips type checking if the key match an item in `skip_type_checking`.
---@param dv any: defaults values
---@param mv any: custom values or modifications .
---@param trace string
---@return string: type of the default value
local check_type = function(dv, mv, trace)
  local dtype = get_type(dv)
  local mtype = get_type(mv)
  local skip = should_skip_type_checking(trace)

  --- hmm I'm not sure about this.
  if dv == nil and not skip then
    return log.error(('Invalid configuration key: `%s`'):format(trace))

  elseif dtype ~= mtype and not skip then
    return log.error(
      ('Unexpcted configuration value for `%s`, expected %s, got %s')
      :format(trace, dtype, mtype)
    )
  end

  return dtype
end

--- Consumes configuration options and sets the values of keys.
--- supports nested keys and values
---@param startkey string: the parent key
---@param d table: default configuration key
---@param m table: the value of startkey
local consume_opts
consume_opts = function(startkey, d, m)
  for k, v in pairs(m) do
    local typ = check_type(d[k], v, ("%s.%s"):format(startkey, k))
    if typ == "table" then
      consume_opts(startkey .. "." .. k, d[k], v)
    else
      d[k] = v
    end
  end
end

--- Set or extend defaults configuration
---@param opts table
config.set = function(opts)
  opts = opts or {}

  if next(opts) ~= nil then
    for k, v in pairs(opts) do
      local typ = check_type(_SwiftEnvConfig[k], v, k)
      if typ ~= "table" then
        _SwiftEnvConfig[k] = v
      else
        consume_opts(k, _SwiftEnvConfig[k], v)
      end
    end
  else
    if vim.tbl_isempty(_SwiftEnvConfig) then
      _SwiftEnvConfig = defaults
      config.values = _SwiftEnvConfig
    end
  end
end

config.set()

return config
