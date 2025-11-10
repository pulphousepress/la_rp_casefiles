local Config = require('config')

local AdminClient = {}
local initialized = false
local uiVisible = false

local function mergeConfig(opts)
    if type(opts) ~= 'table' then return end
    for key, value in pairs(opts) do
        Config[key] = value
    end
end

local function validateOptions(opts)
    if opts ~= nil and type(opts) ~= 'table' then
        return false, 'expected table for options'
    end

    if opts then
        if opts.ToggleCommand and type(opts.ToggleCommand) ~= 'string' then
            return false, 'ToggleCommand must be string'
        end

        if opts.ToggleKey and type(opts.ToggleKey) ~= 'string' then
            return false, 'ToggleKey must be string'
        end

        if opts.logger and type(opts.logger) ~= 'function' then
            return false, 'logger must be function'
        end
    end

    return true
end

local function emitLog(level, message)
    local formatted = string.format('[la_admin][%s] %s', level, message)
    if type(Config.logger) == 'function' then
        local ok, err = pcall(Config.logger, level, message, formatted)
        if not ok then
            print(string.format('[la_admin][warn] logger callback failed: %s', err))
        end
    else
        print(formatted)
    end
    return formatted
end

local function toggleUI(state)
    uiVisible = state and true or false

    if type(SetNuiFocus) == 'function' then
        SetNuiFocus(uiVisible, uiVisible)
    end

    if type(SendNUIMessage) == 'function' then
        SendNUIMessage({ action = 'toggle', show = uiVisible })
    end

    if Config.Debug then
        emitLog('debug', 'UI=' .. tostring(uiVisible))
    end
end

function AdminClient.init(opts)
    if initialized then
        return { ok = true, alreadyInitialized = true }
    end

    local ok, err = validateOptions(opts)
    if not ok then
        return { ok = false, err = err }
    end

    mergeConfig(opts)

    if Config.Enable == false then
        initialized = true
        return { ok = true, disabled = true }
    end

    local commandName = Config.ToggleCommand or '+la_admin_toggle'

    RegisterCommand(commandName, function()
        toggleUI(not uiVisible)
    end, false)

    if type(RegisterKeyMapping) == 'function' then
        RegisterKeyMapping(commandName, 'Toggle Admin Console', 'keyboard', Config.ToggleKey or 'F10')
    end

    if type(RegisterNUICallback) == 'function' then
        RegisterNUICallback('close', function(_, cb)
            toggleUI(false)
            if cb then cb('ok') end
        end)

        RegisterNUICallback('triggerEvent', function(data, cb)
            if type(data) ~= 'table' then
                emitLog('warn', 'triggerEvent invoked without table payload')
                if cb then cb('invalid') end
                return
            end

            if Config.Debug then
                emitLog('debug', 'Event → ' .. tostring(data.event))
            end

            if type(TriggerServerEvent) == 'function' then
                TriggerServerEvent('la_admin:consoleEvent', data.event, data.args or {})
            end

            if cb then cb('ok') end
        end)
    else
        emitLog('warn', 'RegisterNUICallback unavailable; NUI events disabled')
    end

    RegisterCommand('la_debug', function()
        emitLog('info', 'Console Visible=' .. tostring(uiVisible))
    end, false)

    initialized = true

    return { ok = true, command = commandName }
end

return AdminClient
