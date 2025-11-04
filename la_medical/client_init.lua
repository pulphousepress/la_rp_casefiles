local config = require("config")
local medicalClient = require("client")

local result = medicalClient.init(config)
if not result or not result.ok then
    local err = result and result.err or "unknown error"
    print(("[la_medical] failed to initialize client module: %s"):format(err))
end
