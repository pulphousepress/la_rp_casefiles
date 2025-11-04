local Limiter = require("la_weapon_limiter.la_weapon_limiter")
local cfg = require("config")

local result = Limiter.init(cfg)
if not result or not result.ok then
    print("[la_weapon_limiter_standalone] failed to init: " .. (result and result.err or 'unknown'))
end
