-- la_core - minimal loader and exports
-- No hidden globals. Uses local state only.
local Config = require('config')  -- uses the config.lua returned table
local json = json or (function() return { decode = json and json.decode } end) -- rely on global json.decode in fxserver
local codexCache = {
    peds = {},
    vehs = {},
    popgroups = {}
}
local codexVersion = "unknown"

local function safeDecode(raw)
    if not raw then return nil, "no raw content" end
    local ok, parsed = pcall(function() return json.decode(raw) end)
    if not ok then
        return nil, tostring(parsed)
    end
    return parsed
end

local function loadJSONFromCodex(relPath)
    local file = string.format("%s/%s", Config.CodexPath, relPath)
    local raw = LoadResourceFile(Config.CodexPath, relPath)
    if not raw then
        return nil, "file missing: " .. tostring(relPath)
    end
    local parsed, err = safeDecode(raw)
    if not parsed then
        return nil, "json parse error for " .. relPath .. ": " .. tostring(err)
    end
    return parsed
end

local function loadCodex()
    if Config.Debug then print("[la_core] Loading codex from resource: " .. Config.CodexPath) end

    -- attempt to load three core files; tolerate missing files and report
    local ok, res, err

    res, err = loadJSONFromCodex('codex_meta.json')
    if res and res.version then codexVersion = tostring(res.version) end

    res, err = loadJSONFromCodex('whitelists/ped_whitelist.json')
    if res then codexCache.peds = res else print('[la_core] ped whitelist load error: ' .. tostring(err)) end

    res, err = loadJSONFromCodex('whitelists/veh_whitelist.json')
    if res then codexCache.vehs = res else print('[la_core] veh whitelist load error: ' .. tostring(err)) end

    res, err = loadJSONFromCodex('popgroups/veh_popgroups.json')
    if res then codexCache.popgroups = res else print('[la_core] popgroups load error: ' .. tostring(err)) end

    print('[la_core] Codex loaded: version=' .. tostring(codexVersion))
    -- notify others
    TriggerEvent('la_core:CodexLoaded', codexVersion)
    -- asset manifest ready event (payload minimal)
    TriggerEvent('la_core:AssetManifestReady', {version = codexVersion})
end

-- Exports - safe getters (return copies to avoid accidental mutation)
exports('GetCodexVersion', function() return codexVersion end)
exports('GetPedWhitelist', function() return codexCache.peds end)
exports('GetVehicleWhitelist', function() return codexCache.vehs end)
exports('GetPopGroups', function() return codexCache.popgroups end)
exports('ReloadCodex', function() loadCodex() return true end)

-- Helper command for debugging and novice usage
-- run from server console: la_status
RegisterCommand('la_status', function(source, args, raw)
    if source ~= 0 then -- only allow server console or admins to run
        print("[la_core] la_status: console-only command")
        return
    end
    print("la_core status report")
    print("  codex resource: " .. tostring(Config.CodexPath))
    print("  codex version: " .. tostring(codexVersion))
    print("  ped whitelist items: " .. tostring(#(codexCache.peds or {})))
    print("  vehicle whitelist items: " .. tostring(#(codexCache.vehs or {})))
    print("  popgroups entries: " .. tostring(#(codexCache.popgroups or {})))
end, false)

-- resource start hook
AddEventHandler('onResourceStart', function(resName)
    if resName == GetCurrentResourceName() then
        -- load codex after a short wait to allow la_codex to be ensured
        CreateThread(function()
            Wait(1000)
            loadCodex()
        end)
    end
end)
