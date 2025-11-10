local config = require('config')
local adminServer = require('server.main')

local result = adminServer.init(config)
if not result or not result.ok then
    local err = result and result.err or 'unknown error'
    print(('[la_admin] failed to initialize server module: %s'):format(err))
end
