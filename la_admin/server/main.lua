local Config = require('config')

local AdminServer = {}
local initialized = false

local function mergeConfig(opts)
    if type(opts) ~= 'table' then return end
    for key, value in pairs(opts) do
        Config[key] = value
    end
end

local function normalizeAllowedEvents(list)
    if list == nil then return nil end
    if type(list) ~= 'table' then
        return false, 'AllowedEvents must be array of strings'
    end

    local map = {}
    for _, value in ipairs(list) do
        if type(value) ~= 'string' then
            return false, 'AllowedEvents entries must be strings'
        end
        map[value] = true
    end

    return map
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

local function validateOptions(opts)
    if opts ~= nil and type(opts) ~= 'table' then
        return false, 'expected table for options'
    end

    if opts then
        if opts.AllowedEvents then
            local ok, err = normalizeAllowedEvents(opts.AllowedEvents)
            if not ok then
                return false, err
            end
        end

        if opts.logger and type(opts.logger) ~= 'function' then
            return false, 'logger must be function'
        end
    end

    return true
end

function AdminServer.init(opts)
    if initialized then
        return { ok = true, alreadyInitialized = true }
    end

    local ok, err = validateOptions(opts)
    if not ok then
        return { ok = false, err = err }
    end

    mergeConfig(opts)

    local allowedMap
    if Config.AllowedEvents then
        local normalized, normalizeErr = normalizeAllowedEvents(Config.AllowedEvents)
        if not normalized then
            return { ok = false, err = normalizeErr }
        end
        allowedMap = normalized
    end

    if Config.Enable == false then
        initialized = true
        return { ok = true, disabled = true }
    end

    CreateThread(function()
        emitLog('info', 'v1.2.0 Dispatch Console loaded.')
    end)

    RegisterNetEvent('la_admin:consoleEvent', function(event, args)
        local src = source
        local eventName = tostring(event or 'undefined')

        if allowedMap and not allowedMap[eventName] then
            emitLog('warn', ('Blocked console event %s from %s'):format(eventName, tostring(src)))
            return
        end

        local payload = {}
        if type(args) == 'table' then
            payload = args
        end

        local actor = 'console'
        if src and src > 0 and type(GetPlayerName) == 'function' then
            actor = string.format('%s (%s)', GetPlayerName(src) or 'unknown', src)
        elseif src ~= nil then
            actor = tostring(src)
        end

        emitLog('info', string.format('%s triggered %s %s', actor, eventName, json.encode(payload)))

        if type(TriggerEvent) == 'function' then
            TriggerEvent('la_admin:forward', {
                source = src,
                event = eventName,
                args = payload
            })
        end
    end)

    initialized = true

    return { ok = true, allowedEvents = allowedMap }
end

return AdminServer
