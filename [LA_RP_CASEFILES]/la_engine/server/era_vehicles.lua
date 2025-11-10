-- la_engine/server/era_vehicles.lua
-- Era appropriate vehicle gating and helpers.

return function(registry)
    registry:Register({
        id = 'era_vehicles',
        label = 'Era Vehicle Controls',
        order = 20,
        bootstrap = function(ctx)
            local allowedByModel = {}
            local vehiclesCache = {}

            local function rebuildCache()
                local vehicles = ctx.fetchVehicles()
                vehiclesCache = vehicles
                allowedByModel = {}

                for _, entry in ipairs(vehicles) do
                    if type(entry) == 'table' then
                        local model = entry.model
                        if type(model) == 'string' and model ~= '' then
                            allowedByModel[model:lower()] = entry
                        end
                    end
                end

                ctx.log('info', ('Cached %d vehicle entries'):format(#vehicles))
            end

            local function isFactionAllowed(entry, faction)
                if not faction then
                    return true
                end

                local allowed = entry.allowed_factions
                if type(allowed) ~= 'table' or #allowed == 0 then
                    return true
                end

                local factionKey = tostring(faction):lower()
                for _, allowedFaction in ipairs(allowed) do
                    if type(allowedFaction) == 'string' and allowedFaction:lower() == factionKey then
                        return true
                    end
                end

                return false
            end

            local function isVehicleAllowed(model, opts)
                if type(model) ~= 'string' or model == '' then
                    return false, nil
                end

                local entry = allowedByModel[model:lower()]
                if not entry then
                    return false, nil
                end

                opts = opts or {}
                if opts.faction and not isFactionAllowed(entry, opts.faction) then
                    return false, entry
                end

                return true, entry
            end

            ctx.registerExport('IsVehicleAllowed', function(model, opts)
                local allowed, entry = isVehicleAllowed(model, opts)
                return allowed, entry
            end)

            local auditCommand = Config.VehicleAuditCommand or 'la_engine_audit_vehicles'

            RegisterCommand(auditCommand, function(source)
                local total = #vehiclesCache
                local allowedSample = math.min(total, 5)
                local sample, index = {}, 1
                while index <= total and #sample < allowedSample do
                    local entry = vehiclesCache[index]
                    if type(entry) == 'table' and entry.model then
                        sample[#sample + 1] = entry.model
                    end
                    index = index + 1
                end

                local summary = ('vehicles=%d sample=%s'):format(total, table.concat(sample, ', '))
                if source == 0 then
                    ctx.log('info', summary)
                else
                    TriggerClientEvent('chat:addMessage', source, { args = { '^2la_engine', summary } })
                end
            end, false)

            RegisterNetEvent('la_engine:vehicles:audit', function(models)
                local src = source
                local disallowed = {}

                if type(models) == 'table' then
                    for _, model in ipairs(models) do
                        local ok = isVehicleAllowed(model)
                        if not ok then
                            disallowed[#disallowed + 1] = tostring(model)
                        end
                    end
                end

                if #disallowed == 0 then
                    if src == 0 then
                        ctx.log('info', 'Vehicle audit passed (no disallowed models supplied)')
                    else
                        TriggerClientEvent('chat:addMessage', src, { args = { '^2la_engine', 'Vehicle audit passed' } })
                    end
                    return
                end

                local message = ('Disallowed vehicles: %s'):format(table.concat(disallowed, ', '))
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
