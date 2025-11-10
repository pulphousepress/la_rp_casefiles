-- la_engine/server/weather_controller.lua
-- Weather controller system registered with the la_engine runtime.

return function(registry)
    registry:Register({
        id = 'weather_controller',
        label = 'Weather Controller',
        order = 10,
        bootstrap = function(ctx)
            local rules
            local current = { weather = nil, hour = nil }

            local function log(message)
                ctx.log('debug', message)
            end

            local function weightedPick(patterns)
                local total = 0
                for _, pattern in ipairs(patterns or {}) do
                    total = total + (pattern.weight or 1)
                end
                if total <= 0 then
                    return nil
                end

                local roll = math.random() * total
                for _, pattern in ipairs(patterns) do
                    roll = roll - (pattern.weight or 1)
                    if roll <= 0 then
                        return pattern.name
                    end
                end

                local fallback = patterns[#patterns]
                return fallback and fallback.name or nil
            end

            local function maybeTransition(cur, transitions)
                for _, transition in ipairs(transitions or {}) do
                    if transition.from == cur and math.random() < (transition.chance or 0) then
                        return transition.to
                    end
                end
                return cur
            end

            local function broadcast(weather, hour, blend)
                TriggerClientEvent('la_engine:weather:update', -1, weather, hour, blend or 10)
            end

            local function defaultRules()
                return {
                    sync = { intervalMs = Config.WeatherCheckInterval or 60000, default = 'EXTRASUNNY', initialHour = 9, timeScale = 1.0 },
                    patterns = { { name = 'EXTRASUNNY', weight = 1 } },
                    transitions = {},
                }
            end

            local function pullRules()
                local data = ctx.fetchDataset('weather_rules')
                if type(data) ~= 'table' or type(data.sync) ~= 'table' then
                    ctx.log('warn', 'No weather_rules dataset found; using defaults')
                    data = defaultRules()
                end
                rules = data
            end

            local function tickOnce()
                if not rules or not rules.patterns then
                    return
                end

                local pick = weightedPick(rules.patterns) or (rules.sync and rules.sync.default) or 'EXTRASUNNY'
                pick = maybeTransition(pick, rules.transitions)
                current.weather = pick
                current.hour = current.hour or (rules.sync and rules.sync.initialHour) or 9
                broadcast(current.weather, current.hour, 10)
                log(('Weather pick: %s (hour %02d)'):format(current.weather, current.hour))
            end

            local function advanceHour()
                if not rules or not rules.sync then
                    return
                end

                local step = rules.sync.timeScale or 1.0
                local add = math.floor(step)
                if add > 0 then
                    current.hour = ((current.hour or rules.sync.initialHour or 9) + add) % 24
                end
            end

            ctx.onCoreReady(function()
                pullRules()
                current.hour = (rules.sync and rules.sync.initialHour) or 9
                broadcast((rules.sync and rules.sync.default) or 'EXTRASUNNY', current.hour, 0)
            end)

            ctx.onCodexUpdated(function(datasets)
                if datasets.weather_rules then
                    pullRules()
                    ctx.log('info', 'Weather rules refreshed from codex')
                end
            end)

            ctx.registerTick(function()
                while true do
                    if not rules then
                        pullRules()
                    end

                    tickOnce()
                    advanceHour()

                    local interval = (rules and rules.sync and rules.sync.intervalMs) or (Config.WeatherCheckInterval or 60000)
                    Wait(interval)
                end
            end)
        end,
    })
end
