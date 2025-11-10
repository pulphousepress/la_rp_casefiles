local Config = Config or {}

-- Simple client stub for la_engine.
-- Use this to listen for ready events and log status.

RegisterNetEvent('la_core:ready', function()
    if Config.Debug then
        print('[la_engine][client] la_core is ready on client')
    end
end)

-- Provide a test command to print status on client
RegisterCommand('la_engine_status', function()
    print('[la_engine][client] Client status OK')
end, false)