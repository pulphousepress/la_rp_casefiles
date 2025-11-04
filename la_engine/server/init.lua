local config = require('config')
local engine = require('server.main')

local result = engine.init(config)
if not result or not result.ok then
    local err = result and result.err or 'unknown error'
    print(('[la_engine] failed to initialize server module: %s'):format(err))
end
