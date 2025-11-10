-- la_engine/server/ped_gate.lua
-- Ped model gating utilities backed by codex data.

return function(registry)
    registry:Register({
        id = 'ped_gate',
        label = 'Ped Gate',
        order = 30,
        bootstrap = function(ctx)
            local allowedByModel = {}
            local pedCache = {}

            local function rebuildCache()
                local peds = ctx.fetchPeds()
                pedCache = peds
                allowedByModel = {}

                for _, entry in ipairs(peds) do
                    if type(entry) == 'table' then
                        local model = entry.model
                        if type(model) == 'string' and model ~= '' then
                            allowedByModel[model:lower()] = entry
                        end
                    end
                end

                ctx.log('info', ('Cached %d ped entries'):format(#peds))
            end

            local function isPedAllowed(model)
                if type(model) ~= 'string' or model == '' then
                    return false, nil
                end

                local entry = allowedByModel[model:lower()]
                if not entry then
                    return false, nil
                end

                return true, entry
            end

            ctx.registerExport('IsPedAllowed', function(model)
                local ok, entry = isPedAllowed(model)
                return ok, entry
            end)

            local auditCommand = Config.PedAuditCommand or 'la_engine_audit_peds'

            RegisterCommand(auditCommand, function(source)
                local total = #pedCache
                local summary = ('peds=%d'):format(total)
                if source == 0 then
                    ctx.log('info', summary)
                else
                    TriggerClientEvent('chat:addMessage', source, { args = { '^2la_engine', summary } })
                end
            end, false)

            RegisterNetEvent('la_engine:peds:check', function(models)
                local src = source
                local failures = {}

                if type(models) == 'table' then
                    for _, model in ipairs(models) do
                        local ok = isPedAllowed(model)
                        if not ok then
                            failures[#failures + 1] = tostring(model)
                        end
                    end
                end

                if #failures == 0 then
                    if src == 0 then
                        ctx.log('info', 'Ped audit passed')
                    else
                        TriggerClientEvent('chat:addMessage', src, { args = { '^2la_engine', 'Ped audit passed' } })
                    end
                    return
                end

                local message = ('Blocked peds: %s'):format(table.concat(failures, ', '))
                if src == 0 then
                    ctx.log('warn', message)
                else
                    TriggerClientEvent('chat:addMessage', src, { args = { '^1la_engine', message } })
                end
            end)

            ctx.onCoreReady(function()
                rebuildCache()
            end)

            ctx.onCodexUpdated(function()
                rebuildCache()
            end)

            rebuildCache()
        end,
    })
end
