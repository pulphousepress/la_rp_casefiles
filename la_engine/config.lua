local Config = {
    Enable = true,
    Debug = false,
    StatusCommand = 'la_engine_status',
    logger = nil,
    controllers = {}
}
local Config = {}

Config.Debug = true
Config.StartDelay = 2000 -- ms to wait for la_core

return Config
