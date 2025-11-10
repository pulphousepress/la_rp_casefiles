-- la_admin/server/addons_registry.lua
-- Lightweight addon registry powering the admin control surface.

local Registry = {
    _addons = {},
    _order = {},
    _indices = {},
}

local function cloneList(list)
    local out = {}
    for i = 1, #list do
        out[i] = list[i]
    end
    return out
end

local function cloneDescriptor(descriptor)
    local copy = {}
    for key, value in pairs(descriptor) do
        if type(value) == 'table' then
            copy[key] = cloneList(value)
        else
            copy[key] = value
        end
    end
    return copy
end

local function sanitizeString(value, fallback)
    if type(value) ~= 'string' then
        return fallback
    end
    local trimmed = value:match('^%s*(.-)%s*$')
    if trimmed == '' then
        return fallback
    end
    return trimmed
end

local function sanitizeList(values)
    if type(values) ~= 'table' then
        if type(values) == 'string' and values ~= '' then
            values = { values }
        else
            return {}
        end
    end

    local result, seen = {}, {}
    for _, raw in ipairs(values) do
        if type(raw) == 'string' then
            local trimmed = raw:match('^%s*(.-)%s*$')
            if trimmed ~= '' then
                local key = trimmed:lower()
                if not seen[key] then
                    seen[key] = true
                    result[#result + 1] = trimmed
                end
            end
        end
    end

    table.sort(result)
    return result
end

local function upsert(descriptor)
    local resource = sanitizeString(descriptor.resource, GetInvokingResource() or descriptor.id or descriptor.name or 'unknown')
    local name = sanitizeString(descriptor.name, resource)

    local normalized = {
        id = sanitizeString(descriptor.id, resource),
        name = name,
        resource = resource,
        version = sanitizeString(descriptor.version, '1.0.0'),
        description = sanitizeString(descriptor.description, ''),
        hooks = sanitizeList(descriptor.hooks),
        provides = sanitizeList(descriptor.provides or descriptor.capabilities),
        maintainer = sanitizeString(descriptor.maintainer or descriptor.author, ''),
        registered_at = os.time(),
    }

    if not Registry._indices[resource] then
        Registry._order[#Registry._order + 1] = resource
        Registry._indices[resource] = #Registry._order
    end

    Registry._addons[resource] = normalized
    print(('[la_admin][info] addon registered resource=%s name=%s capabilities=%s'):format(
        resource,
        name,
        (#normalized.provides > 0 and table.concat(normalized.provides, ', ')) or 'none'
    ))

    return normalized
end

function Registry.register(descriptor)
    if type(descriptor) ~= 'table' then
        return false, 'descriptor must be a table'
    end

    local normalized = upsert(descriptor)
    return true, cloneDescriptor(normalized)
end

function Registry.getAll()
    local results = {}
    for _, resource in ipairs(Registry._order) do
        local descriptor = Registry._addons[resource]
        if descriptor then
            results[#results + 1] = cloneDescriptor(descriptor)
        end
    end
    return results
end

local function hasCapability(descriptor, capability)
    local provides = descriptor.provides
    if type(provides) ~= 'table' then
        return false
    end

    local key = capability:lower()
    for _, value in ipairs(provides) do
        if type(value) == 'string' and value:lower() == key then
            return true
        end
    end

    return false
end

function Registry.getByCapability(capability)
    capability = sanitizeString(capability, nil)
    if not capability then
        return Registry.getAll()
    end

    local results = {}
    for _, resource in ipairs(Registry._order) do
        local descriptor = Registry._addons[resource]
        if descriptor and hasCapability(descriptor, capability) then
            results[#results + 1] = cloneDescriptor(descriptor)
        end
    end
    return results
end

function Registry.count()
    return #Registry._order
end

return Registry
