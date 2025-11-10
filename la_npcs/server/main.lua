local Config = require("config")
local Shared = require("ph_shared").new("la_npcs")

local NPCServer = {}
local initialized = false

local function emitLog(level, message)
    local msg = string.format("[la_npcs][%s] %s", level, message)
    print(msg)
    return msg
end

local function mergeConfig(opts)
    if type(opts) ~= "table" then return end
    for key, value in pairs(opts) do
        Config[key] = value
    end
end

local function ensureOxMySQL()
    if not exports or not exports.oxmysql then
        return false, "oxmysql export not found"
    end
    if type(exports.oxmysql.execute) ~= "function" or type(exports.oxmysql.executeSync) ~= "function" then
        return false, "oxmysql exports missing execute/executeSync"
    end
    return true
end

local function bootstrapTables()
    exports.oxmysql:execute([[CREATE TABLE IF NOT EXISTS la_flags (
        name VARCHAR(64) PRIMARY KEY,
        value TINYINT(1) NOT NULL DEFAULT 0,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    exports.oxmysql:execute([[CREATE TABLE IF NOT EXISTS ped_whitelist (
        id INT AUTO_INCREMENT PRIMARY KEY,
        model VARCHAR(191) NOT NULL UNIQUE,
        category VARCHAR(64),
        label VARCHAR(191),
        notes TEXT,
        added_by VARCHAR(64),
        added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])

    local existing = exports.oxmysql:executeSync([[SELECT COUNT(1) AS cnt
        FROM information_schema.statistics
        WHERE table_schema = DATABASE() AND table_name = 'ped_whitelist' AND index_name = 'idx_ped_category'
    ]])

    local count = 0
    if existing and existing[1] and existing[1].cnt ~= nil then
        count = tonumber(existing[1].cnt) or 0
    end

    if count == 0 then
        exports.oxmysql:execute([[CREATE INDEX idx_ped_category ON ped_whitelist (category);]])
    end


local NPCServer = {}

local function emitLog(level, message)
    local msg = string.format("[la_npcs][%s] %s", level, message)
    print(msg)
    return msg
end

local function mergeConfig(opts)
    if type(opts) ~= "table" then return end
    for key, value in pairs(opts) do
        Config[key] = value
    end
end

local function bootstrapTables()
    exports.oxmysql:execute([[ 
        CREATE TABLE IF NOT EXISTS la_flags (
            name VARCHAR(64) PRIMARY KEY,
            value TINYINT(1) NOT NULL DEFAULT 0,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    exports.oxmysql:execute([[ 
        CREATE TABLE IF NOT EXISTS ped_whitelist (
            id INT AUTO_INCREMENT PRIMARY KEY,
            model VARCHAR(191) NOT NULL UNIQUE,
            category VARCHAR(64),
            label VARCHAR(191),
            notes TEXT,
            added_by VARCHAR(64),
            added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    exports.oxmysql:execute([[ 
        CREATE INDEX IF NOT EXISTS idx_ped_category ON ped_whitelist (category);
    ]])

    emitLog("info", "DB bootstrap complete")
end

local baseSeed = {
    { model = "a_c_cat_01",    label = "Cat (ambient)", notes = "Default GTA animal ped", category = "animal_models",  added_by = "server_import" },
    { model = "a_c_husky",     label = "Husky (dog)",   notes = "Ambient dog ped",        category = "animal_models",  added_by = "server_import" },
    { model = "FilmNoir",      label = "Film Noir",     notes = "Noir-themed NPC",        category = "ambient_males",  added_by = "server_import" },
    { model = "Doorman01SMY",  label = "Doorman",       notes = "Door staff ped",         category = "scenario_male",  added_by = "server_import" },
}

local function insertPeds(entries, quiet)
    if type(entries) ~= "table" or #entries == 0 then return 0 end
    local inserted = 0
    for _, e in ipairs(entries) do
        exports.oxmysql:execute(
            "INSERT IGNORE INTO ped_whitelist (model, category, label, notes, added_by) VALUES (?, ?, ?, ?, ?)",
            { e.model, e.category, e.label or e.model, e.notes or '', e.added_by or 'system' },
            function(result)
                if type(result) == "table" and result.affectedRows and result.affectedRows > 0 then
                    inserted = inserted + 1
                    if not quiet then
                        emitLog("info", ("+ %s (%s)"):format(e.model, e.category or "unknown"))
                    end
                end
            end
        )
    end
    return inserted
end

local function loadPedsJSON()
    local file = LoadResourceFile(GetCurrentResourceName(), "data/peds.json")
    if not file then
        emitLog("warn", "data/peds.json not found; skipping JSON import")
        return {}
    end
    local ok, data = pcall(json.decode, file)
    if not ok or type(data) ~= "table" then
        emitLog("error", "Failed to decode data/peds.json; skipping")
        return {}
    end

    local bulk = {}
    for category, list in pairs(data) do
        if type(list) == "table" then
            for _, model in ipairs(list) do
                bulk[#bulk+1] = {
                    model    = model,
                    category = category,
                    label    = model,
                    notes    = ("Imported from peds.json (%s)"):format(category),
                    added_by = "json_import"
                }
            end
        end
    end
    return bulk
end

local function getFlag(name)
    local cache = Shared:get("flag:" .. name)
    if cache.ok and cache.value ~= nil then
        return cache.value
    end
    local r = exports.oxmysql:executeSync("SELECT value FROM la_flags WHERE name = ? LIMIT 1", { name })
    local value = false
    if r and r[1] then
        value = tonumber(r[1].value) == 1
    end
    Shared:set("flag:" .. name, value)
    return value
end

local function setFlag(name, val)
    exports.oxmysql:execute("REPLACE INTO la_flags (name, value) VALUES (?, ?)", { name, val and 1 or 0 })
    Shared:set("flag:" .. name, val and true or false)
end

local function seedOnce()
    if getFlag("ped_seed") then
        emitLog("info", "Seed previously completed; skipping")
        return
    end

    emitLog("info", "Running one-time seed")
    insertPeds(baseSeed, true)

    local jsonBulk = loadPedsJSON()
    if #jsonBulk > 0 then
        emitLog("info", ("Importing %d peds from JSON"):format(#jsonBulk))
        insertPeds(jsonBulk, true)
    end

    setFlag("ped_seed", true)
    emitLog("info", "Seed complete")
end

local function registerCallbacks()
    lib.callback.register("la_npcs:getWhitelist", function()
        local results = exports.oxmysql:executeSync("SELECT model FROM ped_whitelist")
        if not results or #results == 0 then
            emitLog("warn", "No entries in ped_whitelist; returning nil")
            return nil
        end
        local models = {}
        for _, row in ipairs(results) do
            models[#models+1] = row.model
        end
        emitLog("info", ("Synced %d ped models from DB → clients"):format(#models))
        return models
    end)
end

local function registerCommands()
    RegisterCommand("la_import_peds", function(source)
        local isConsole = (source == 0)
        local allowed = isConsole or IsPlayerAceAllowed(source, "la.npcsuite.admin") or IsPlayerAceAllowed(source, "admin")
        if not allowed then
            emitLog("warn", "Permission denied for /la_import_peds")
            return
        end

        emitLog("info", "Manual import starting")
        insertPeds(baseSeed, false)
        local bulk = loadPedsJSON()
        if #bulk > 0 then
            emitLog("info", ("Importing %d peds from JSON"):format(#bulk))
            insertPeds(bulk, false)
        end
        emitLog("info", "Manual import complete")
    end, true)
end

function NPCServer.init(opts)
    if initialized then
        return { ok = true, alreadyInitialized = true }
    end

    mergeConfig(opts)

    local ok, err = ensureOxMySQL()
    if not ok then
        return { ok = false, err = err }
    end


local function registerCommands()
    RegisterCommand("la_import_peds", function(source)
        local isConsole = (source == 0)
        local allowed = isConsole or IsPlayerAceAllowed(source, "la.npcsuite.admin") or IsPlayerAceAllowed(source, "admin")
        if not allowed then
            emitLog("warn", "Permission denied for /la_import_peds")
            return
        end

        emitLog("info", "Manual import starting")
        insertPeds(baseSeed, false)
        local bulk = loadPedsJSON()
        if #bulk > 0 then
            emitLog("info", ("Importing %d peds from JSON"):format(#bulk))
            insertPeds(bulk, false)
        end
        emitLog("info", "Manual import complete")
    end, true)
end

function NPCServer.init(opts)
    mergeConfig(opts)
    bootstrapTables()
    registerCallbacks()
    registerCommands()

    if Config.seedOnStart ~= false then
        seedOnce()
    end

    AddEventHandler("onResourceStart", function(resource)
        if resource ~= GetCurrentResourceName() then return end
        seedOnce()
    end)

    initialized = true
    emitLog("info", "v1.4.1 server module initialized")
    return { ok = true }
end

NPCServer.init(Config)

return NPCServer
