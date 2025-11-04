local config = require("config")
local limiter = require("la_weapon_limiter")

local result = limiter.init(config)
if not result or not result.ok then
    local err = result and result.err or "unknown error"
    print(("[la_weapon_limiter] failed to initialize: %s"):format(err))
end
