local medicalServer = require("server")

local result = medicalServer.init()
if not result or not result.ok then
    local err = result and result.err or "unknown error"
    print(("[la_medical] failed to initialize server module: %s"):format(err))
end
