local Config = {
    EnableCore = true,
    Debug = false,
    StatusCommand = "la_status",
    logger = nil
}
-- la_core config
local Config = {}

-- resource name where codex lives (adjust if needed)
Config.CodexPath = 'la_codex'

-- if true and oxmysql present, la_core will expose a function to seed DB (manual trigger)
Config.SyncToDB = false

-- debug prints to server console
Config.Debug = true

return Config
