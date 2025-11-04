local Engine = require('la_engine.server.main')
local cfg = require('config')

local result = Engine.init(cfg)
if not result or not result.ok then
    local err = result and result.err or 'unknown error'
    print(('[la_engine_standalone] failed to init: %s'):format(err))
end
