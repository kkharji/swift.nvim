local M = {}
local format = require'swift_env.format'
local config = require'swift_env.config'

M.setup = function(opts)
  config.set(opts)
end

M.attach = function(opts)
  format.attach()
end

return M
