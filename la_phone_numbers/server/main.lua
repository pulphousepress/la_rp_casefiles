-- server/main.lua (replace GenerateEraPhoneNumber with this)

local Config = Config or {}

local function getPrefixForZone(zone)
    if not zone or zone == "" then return Config.DefaultPrefix end
    local lowerZone = string.lower(zone)
    for _, ex in ipairs(Config.Exchanges) do
        if string.find(lowerZone, string.lower(ex.zone)) then
            return ex.prefix
        end
    end
    return Config.DefaultPrefix
end

-- Check DB for existing phone number in players or npwd contacts
local function phoneExistsInDB(phone)
    local p = MySQL.single.await("SELECT 1 FROM players WHERE phone_number = ? LIMIT 1", { phone })
    if p then return true end
    local c = MySQL.single.await("SELECT 1 FROM npwd_phone_contacts WHERE number = ? LIMIT 1", { phone })
    return c and true or false
end

-- Generate a unique era phone number (tries a few times)
local function generateUnique(prefix)
    for i = 1, 15 do
        local digits = string.format("%03d", math.random(100, 999))
        local num = prefix .. digits
        if not phoneExistsInDB(num) then
            return num
        end
    end
    -- fallback: append a 4-digit random if collisions occur
    return prefix .. tostring(math.random(1000, 9999))
end

function GenerateEraPhoneNumber(zone)
    local prefix = getPrefixForZone(zone)
    return generateUnique(prefix)
end
exports('GenerateEraPhoneNumber', GenerateEraPhoneNumber)

RegisterCommand('la_phone_debug', function(source, args)
    local zone = table.concat(args, " ")
    local num = GenerateEraPhoneNumber(zone)
    print(("[LA_PHONE] Generated number for '%s': %s"):format(zone ~= "" and zone or "Unknown", num))
    if source > 0 then
        TriggerClientEvent('chat:addMessage', source, {
            args = { '^3Los Animales Operator', ('Generated number: ^2%s'):format(num) }
        })
    end
end, true)
