local Core = require("la_core.server.main")
local cfg = require("config")

local result = Core.init(cfg)

if not result or not result.ok then
    local err = result and result.err or "unknown error"
    print(("[la_core_standalone] failed to init: %s"):format(err))
end
