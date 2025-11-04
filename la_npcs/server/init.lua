local config = require("config")
local npcServer = require("server.main")

local result = npcServer.init(config)
if not result or not result.ok then
    local err = result and result.err or "unknown error"
    print(("[la_npcs] failed to initialize server module: %s"):format(err))
end
