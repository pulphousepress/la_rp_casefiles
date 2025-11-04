local Config = require("config")

local CoreClient = {}
local initialized = false

local function mergeConfig(opts)
    if type(opts) ~= "table" then return end
    for key, value in pairs(opts) do
        Config[key] = value
    end
end

local function validateOptions(opts)
    if opts == nil then
        return true
    end

    if type(opts) ~= "table" then
        return false, "expected table for options"
    end

    if opts.StatusCommand and type(opts.StatusCommand) ~= "string" then
        return false, "StatusCommand must be string"
    end

    return true
end

function CoreClient.init(opts)
    if initialized then
        return { ok = true, alreadyInitialized = true }
    end

    local ok, err = validateOptions(opts)
    if not ok then
        return { ok = false, err = err }
    end

    mergeConfig(opts)

    local commandName = Config.StatusCommand or "la_status"

    RegisterCommand(commandName, function()
        print("[la_core] Active=true")
    end, false)

    initialized = true

    return { ok = true, command = commandName }
end

return CoreClient
