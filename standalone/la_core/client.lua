local CoreClient = require("la_core.client.main")
local cfg = require("config")

local result = CoreClient.init(cfg)

if not result or not result.ok then
    local err = result and result.err or "unknown error"
    print(("[la_core_standalone] client init failed: %s"):format(err))
end
