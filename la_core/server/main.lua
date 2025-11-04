local Config = require("config")

local Core = {}
local initialized = false

local function mergeConfig(opts)
    if type(opts) ~= "table" then return end
    for key, value in pairs(opts) do
        Config[key] = value
    end
end

local function emitLog(level, message)
    local msg = string.format("[la_core][%s] %s", level, message)

    if type(Config.logger) == "function" then
        local ok, err = pcall(Config.logger, level, message, msg)
        if not ok then
            print(string.format("[la_core][warn] logger callback failed: %s", err))
        end
    else
        print(msg)
    end

    if type(TriggerEvent) == "function" then
        TriggerEvent("txAdmin:tableEvent", "custom:log", {
            source = "la_core",
            level = level,
            message = message,
            formatted = msg
        })
    end

    return msg
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

    if opts.logger and type(opts.logger) ~= "function" then
        return false, "logger must be function"
    end

    return true
end

function Core.init(opts)
    if initialized then
        return { ok = true, alreadyInitialized = true }
    end

    local ok, err = validateOptions(opts)
    if not ok then
        return { ok = false, err = err }
    end

    mergeConfig(opts)

    local commandName = Config.StatusCommand or "la_status"

    RegisterCommand(commandName, function(source)
        local msg = emitLog("info", "Active=true")
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, { args = { msg } })
        end
    end, false)

    CreateThread(function()
        emitLog("info", "v1.0.2 loaded on server.")
    end)

    initialized = true

    return { ok = true, command = commandName }
end

return Core
