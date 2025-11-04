local Shared = {}
Shared.__index = Shared

local function sanitizeKey(key)
    if type(key) ~= 'string' then
        return nil, 'ph_shared keys must be strings'
    end
    return key
end

function Shared.new(name, opts)
    return setmetatable({
        name = name or 'ph_shared',
        state = {},
        readonly = opts and opts.readonly or false
    }, Shared)
end

function Shared:get(key)
    local normalized, err = sanitizeKey(key)
    if not normalized then
        return { ok = false, err = err }
    end
    return { ok = true, value = self.state[normalized] }
end

function Shared:set(key, value)
    if self.readonly then
        return { ok = false, err = 'store is read-only' }
    end
    local normalized, err = sanitizeKey(key)
    if not normalized then
        return { ok = false, err = err }
    end
    self.state[normalized] = value
    return { ok = true, value = value }
end

function Shared:merge(tbl)
    if self.readonly then
        return { ok = false, err = 'store is read-only' }
    end
    if type(tbl) ~= 'table' then
        return { ok = false, err = 'expected table' }
    end
    for key, value in pairs(tbl) do
        local result = self:set(key, value)
        if not result.ok then
            return result
        end
    end
    return { ok = true }
end

local API = {
    new = function(name, opts)
        return Shared.new(name, opts)
    end
}

if package and package.loaded then
    package.loaded['ph_shared'] = API
end

return API
