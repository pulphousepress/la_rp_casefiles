Config = {}

Config.Enable = true
Config.Debug  = false

-- force dusk time
Config.LockTime   = true
Config.TimeHour   = 19   -- 7pm
Config.TimeMinute = 30

-- noir global cycle (always raining/foggy)
Config.TickSeconds   = 600   -- 10 min per roll
Config.NoirWeathers  = { "RAIN", "THUNDER", "FOGGY", "CLOUDS" }

-- Toontown zone (always sunny)
Config.ToontownCenter = vector3(-1422.0, -285.0, 46.0)
Config.ToontownRadius = 120.0
Config.ToonWeather    = "EXTRASUNNY"

-- Progressive north zones
Config.VinewoodY   = 1200.0   -- north of Vinewood sign
Config.SandyY      = 3500.0   -- north of Sandy Shores

Config.VinewoodWeather = { "RAIN", "THUNDER", "OVERCAST" }
Config.SandyWeather    = { "THUNDER", "SNOW", "BLIZZARD" }
