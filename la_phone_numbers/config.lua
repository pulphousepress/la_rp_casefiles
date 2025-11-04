-- la_phone_numbers / config.lua
-- 1950s-style exchange prefixes by district for Los Animales RP

Config = {}

Config.Exchanges = {
    { zone = "Mission Row",  prefix = "LAMR" },
    { zone = "Vinewood",     prefix = "LAVW" },
    { zone = "Del Perro",    prefix = "LADP" },
    { zone = "Rancho",       prefix = "LARN" },
    { zone = "Mirror Park",  prefix = "LAMP" },
    { zone = "Downtown",     prefix = "LADT" },
    { zone = "Sandy Shores", prefix = "LASS" },
    { zone = "Paleto",       prefix = "LAPB" },
    { zone = "Morningwood",  prefix = "LAMW" },
    { zone = "Richman",      prefix = "LARM" },
    { zone = "Vespucci",     prefix = "LAVP" }
}

-- Fallback prefix if zone not found
Config.DefaultPrefix = "LAUN"
