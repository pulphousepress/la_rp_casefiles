--------------------------------------------
-- Los Animales RP : la_npcs v1.4.1
-- Purpose: One-time DB seed + JSON import with category tags
-- Notes:
--  - Creates tables/indexes if missing
--  - Seeds only once (flagged in la_flags)
--  - Manual re-seed: /la_import_peds (ACE: la.npcsuite.admin or console)
--------------------------------------------

local RES = GetCurrentResourceName()

CreateThread(function()
    print("[la_npcs] v1.4.1 (one-time seed + JSON sync + category tagging) initializing...")
end)

-------------------------------------------------
-- DB BOOTSTRAP: tables & indexes
-------------------------------------------------
CreateThread(function()
    -- Meta flags table to track one-time operations
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS la_flags (
            name VARCHAR(64) PRIMARY KEY,
            value TINYINT(1) NOT NULL DEFAULT 0,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    -- Main whitelist
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

    -- Helpful indexes (safe if already exist)
    exports.oxmysql:execute([[
        CREATE INDEX IF NOT EXISTS idx_ped_category ON ped_whitelist (category);
    ]])

    print("[la_npcs] DB bootstrap complete.")
end)

-------------------------------------------------
-- SAFE BASE SEED (minimal set for empty DBs)
-------------------------------------------------
local baseSeed = {
    { model = "a_c_cat_01",    label = "Cat (ambient)", notes = "Default GTA animal ped", category = "animal_models",  added_by = "server_import" },
    { model = "a_c_husky",     label = "Husky (dog)",   notes = "Ambient dog ped",        category = "animal_models",  added_by = "server_import" },
    { model = "FilmNoir",      label = "Film Noir",     notes = "Noir-themed NPC",        category = "ambient_males",  added_by = "server_import" },
    { model = "Doorman01SMY",  label = "Doorman",       notes = "Door staff ped",         category = "scenario_male",  added_by = "server_import" },
}

-------------------------------------------------
-- INSERT HELPERS
-------------------------------------------------
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
                        print(("[la_npcs] + %s (%s)"):format(e.model, e.category or "unknown"))
                    end
                end
            end
        )
    end
    return inserted
end

local function loadPedsJSON()
    local file = LoadResourceFile(RES, "data/peds.json")
    if not file then
        print("[la_npcs] WARN: data/peds.json not found; skipping JSON import.")
        return {}
    end
    local ok, data = pcall(json.decode, file)
    if not ok or type(data) ~= "table" then
        print("[la_npcs] ERROR: Failed to decode data/peds.json; skipping.")
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

-------------------------------------------------
-- ONE-TIME SEED LOGIC
-------------------------------------------------
local function getFlag(name)
    local r = exports.oxmysql:executeSync("SELECT value FROM la_flags WHERE name = ? LIMIT 1", { name })
    if r and r[1] then return tonumber(r[1].value) == 1 end
    return false
end

local function setFlag(name, val)
    exports.oxmysql:execute("REPLACE INTO la_flags (name, value) VALUES (?, ?)", { name, val and 1 or 0 })
end

local function seedOnce()
    -- If already seeded, skip
    if getFlag("ped_seed") then
        print("[la_npcs] Seed previously completed; skipping.")
        return
    end

    print("[la_npcs] Running one-time seed...")
    insertPeds(baseSeed, true)

    local jsonBulk = loadPedsJSON()
    if #jsonBulk > 0 then
        print(("[la_npcs] Importing %d peds from JSON..."):format(#jsonBulk))
        insertPeds(jsonBulk, true)
    end

    setFlag("ped_seed", true)
    print("[la_npcs] Seed complete.")
end

-------------------------------------------------
-- RESOURCE START: seed once, then ready
-------------------------------------------------
AddEventHandler("onResourceStart", function(resource)
    if resource ~= RES then return end
    seedOnce()
end)

-------------------------------------------------
-- ADMIN COMMANDS
-------------------------------------------------
RegisterCommand("la_import_peds", function(source)
    local isConsole = (source == 0)
    local allowed = isConsole or IsPlayerAceAllowed(source, "la.npcsuite.admin") or IsPlayerAceAllowed(source, "admin")
    if not allowed then
        print("[la_npcs] Permission denied for /la_import_peds")
        return
    end

    -- Re-seed on demand: base + JSON (idempotent via INSERT IGNORE)
    print("[la_npcs] Manual import starting...")
    insertPeds(baseSeed, false)
    local bulk = loadPedsJSON()
    if #bulk > 0 then
        print(("[la_npcs] Importing %d peds from JSON..."):format(#bulk))
        insertPeds(bulk, false)
    end
    print("[la_npcs] Manual import complete.")
end, true)

-------------------------------------------------
-- DB → CLIENT SYNC CALLBACK
-------------------------------------------------
lib.callback.register("la_npcs:getWhitelist", function()
    local results = exports.oxmysql:executeSync("SELECT model FROM ped_whitelist")
    if not results or #results == 0 then
        print("[la_npcs] No entries in ped_whitelist; returning nil.")
        return nil
    end
    local models = {}
    for _, row in ipairs(results) do
        models[#models+1] = row.model
    end
    print(("[la_npcs] Synced %d ped models from DB → clients."):format(#models))
    return models
end)
