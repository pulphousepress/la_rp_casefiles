local config = require('config')
local adminClient = require('client.main')

local result = adminClient.init(config)
if not result or not result.ok then
    local err = result and result.err or 'unknown error'
    print(('[la_admin] failed to initialize client module: %s'):format(err))
end
