local config = require("config")
local npcClient = require("client.main")

local result = npcClient.init(config)
if not result or not result.ok then
    local err = result and result.err or "unknown error"
    print(("[la_npcs] failed to initialize client module: %s"):format(err))
end
