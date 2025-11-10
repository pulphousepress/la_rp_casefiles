-- la_admin/server/commands.lua
-- Registers control-surface commands for operators.

local Commands = {}
local registered = false

local function formatStatus(status)
    if type(status) ~= 'table' then
        return 'la_core status unavailable'
    end

    local codexState = status.codex_ok and 'ok' or 'error'
    local vehicles = status.vehicles_count or 0
    local peds = status.peds_count or 0
    local factions = status.factions_count or 0
    local addons = status.addons_registered or 0

    return ('codex=%s vehicles=%d peds=%d factions=%d addons=%d'):format(codexState, vehicles, peds, factions, addons)
end

local function sendMessage(source, message)
    if source == 0 then
        print('[la_admin] ' .. message)
        return
    end

    TriggerClientEvent('chat:addMessage', source, { args = { '^2la_admin', message } })
end

local function isAllowed(ctx, source)
    if source == 0 then
        return true
    end

    local config = ctx.config or {}
    if config.AllowAnyoneInDev then
        return true
    end

    local principal = config.AcePrincipal or 'group.admin'
    return IsPlayerAceAllowed(source, principal)
end

local function describeAddon(addon)
    local provides = addon.provides or {}
    local providesText = (#provides > 0) and table.concat(provides, ', ') or 'none'
    local hooks = addon.hooks or {}
    local hooksText = (#hooks > 0) and table.concat(hooks, ', ') or 'none'
    local version = addon.version or '1.0.0'
    local name = addon.name or addon.resource or 'unknown'
    return ('%s v%s — provides [%s], hooks [%s]'):format(name, version, providesText, hooksText)
end

function Commands.register(ctx)
    if registered then
        return
    end
    registered = true

    ctx = ctx or {}
    local config = ctx.config or Config or {}
    local statusCommand = config.StatusCommand or 'la_status'
    local addonsCommand = config.AddonsCommand or 'la_addons'

    RegisterCommand(statusCommand, function(source)
        if not isAllowed(ctx, source) then
            return
        end

        local status = ctx.getStatus and ctx.getStatus() or { codex_ok = false }
        sendMessage(source, formatStatus(status))
    end, false)

    RegisterCommand(addonsCommand, function(source, args)
        if not isAllowed(ctx, source) then
            return
        end

        local capability = args and args[1]
        local results
        if capability and capability ~= '' then
            results = ctx.registry and ctx.registry.getByCapability and ctx.registry.getByCapability(capability) or {}
        else
            results = ctx.registry and ctx.registry.getAll and ctx.registry.getAll() or {}
        end

        if #results == 0 then
            sendMessage(source, 'no addons registered')
            return
        end

        sendMessage(source, ('addons=%d capability=%s'):format(#results, capability or 'any'))
        for _, addon in ipairs(results) do
            sendMessage(source, describeAddon(addon))
        end
    end, false)
end

return Commands
