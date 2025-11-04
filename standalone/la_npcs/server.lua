local NPCServer = require("la_npcs.server.main")
local cfg = require("config")

local result = NPCServer.init(cfg)

if not result or not result.ok then
    local err = result and result.err or "unknown error"
    print(("[la_npcs_standalone] init failed: %s"):format(err))
end
