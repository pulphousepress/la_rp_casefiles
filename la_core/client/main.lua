-- client/main.lua (la_core client helper)
-- Local state only, no globals
local client = {}
local isAppearanceOpen = false
local lastCodexVersion = "unknown"

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
end)

    mergeConfig(opts)

    local commandName = Config.StatusCommand or "la_status"

    RegisterCommand(commandName, function()
        print("[la_core] Active=true")
    end, false)

    initialized = true

    return { ok = true, command = commandName }
end
-- NUI callback handler (if you implement NUI)
RegisterNUICallback("close", function(data, cb)
    closeAppearance()
    cb({ ok = true })
end)

-- Exported functions for other client resources
exports("IsAppearanceOpen", function() return isAppearanceOpen end)
exports("ToggleAppearance", function() return client.toggleAppearance() end)

-- Client ready message
CreateThread(function()
    Wait(500) -- give some time for resource startup
    dbg("client helper ready")
end)
