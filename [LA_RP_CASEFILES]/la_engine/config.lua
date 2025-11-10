-- la_engine/config.lua
-- Shared runtime configuration for engine systems.

Config = Config or {}

Config.Debug = Config.Debug or false
Config.WeatherCheckInterval = Config.WeatherCheckInterval or 60000 -- ms between weather ticks
Config.VehicleAuditCommand = Config.VehicleAuditCommand or 'la_engine_audit_vehicles'
Config.PedAuditCommand = Config.PedAuditCommand or 'la_engine_audit_peds'
