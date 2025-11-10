-- Manifest describing the available datasets within la_codex.
-- Data sets are static Lua tables under `sets/`. SQL seeds live under `sql/`.
return {
    version = "1.0.0",  -- static version string
    sets = {
        weather         = 'sets/weather.lua',
        npcs            = 'sets/npcs.lua',
        weather_rules   = 'sets/weather_rules.lua',
        era_vehicles    = 'sets/era_vehicles.lua',
        era_peds        = 'sets/era_peds.lua'
    },
    sql = {
        seed = 'sql/seed.sql'
    }
}
