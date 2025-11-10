-- la_core/server/addons_registry.lua — centralized addon registry
local CORE = GetCurrentResourceName()

local Registry = {
  _addons = {},
  _categories = {},
  _ordered = {},
}

local function sanitizeCategory(value)
  if type(value) ~= 'string' or value == '' then return 'misc' end
  return value:lower()
end

local function sanitizeCapability(value)
  if type(value) ~= 'string' or value == '' then return nil end
  return value:lower()
end

local function copyList(list)
  local out = {}
  for i = 1, #list do out[i] = list[i] end
  return out
end

local function copyMap(map)
  local out = {}
  for k, v in pairs(map) do out[k] = v end
  return out
end

local function normalizeCapabilities(values)
  if type(values) ~= 'table' then
    if type(values) == 'string' then values = { values } else values = {} end
  end

  local set, ordered = {}, {}
  for _, raw in ipairs(values) do
    local cap = sanitizeCapability(raw)
    if cap and not set[cap] then
      set[cap] = true
      ordered[#ordered+1] = cap
    end
  end

  table.sort(ordered)
  return ordered, set
end

local function cloneDescriptor(descriptor)
  local copy = {}
  for k, v in pairs(descriptor) do
    if k ~= '_capabilityIndex' then
      if type(v) == 'table' then
        if k == 'capabilities' then
          copy[k] = copyList(v)
        else
          copy[k] = copyMap(v)
        end
      else
        copy[k] = v
      end
    end
  end
  return copy
end

local function ensureCategorySlot(category, template)
  category = sanitizeCategory(category)
  local entry = Registry._categories[category]
  if not entry then
    entry = {
      name = category,
      label = template and template.label or category,
      description = template and template.description or '',
      icon = template and template.icon or nil,
      createdAt = os.time(),
    }
    Registry._categories[category] = entry
  else
    if template then
      entry.label = template.label or entry.label
      entry.description = template.description or entry.description
      entry.icon = template.icon or entry.icon
    end
  end
  return entry
end

function Registry.seedCategories(definitions)
  if type(definitions) ~= 'table' then return end
  for _, def in ipairs(definitions) do
    if type(def) == 'string' then
      ensureCategorySlot(def)
    elseif type(def) == 'table' and def.name then
      ensureCategorySlot(def.name, def)
    end
  end
end

local function upsertAddon(resource, descriptor)
  local normalized = {
    resource = resource,
    name = descriptor.name or resource,
    version = descriptor.version or '0.0.0',
    description = descriptor.description or '',
    author = descriptor.author or descriptor.maintainer or 'unknown',
    homepage = descriptor.homepage,
    category = sanitizeCategory(descriptor.category),
    status = descriptor.status or 'active',
    metadata = type(descriptor.metadata) == 'table' and copyMap(descriptor.metadata) or nil,
    registeredAt = os.time(),
  }

  normalized.capabilities, normalized._capabilityIndex = normalizeCapabilities(descriptor.capabilities or descriptor.capability)
  ensureCategorySlot(normalized.category)

  Registry._addons[resource] = normalized

  local found = false
  for i = 1, #Registry._ordered do
    if Registry._ordered[i] == resource then
      found = true
      break
    end
  end
  if not found then
    Registry._ordered[#Registry._ordered+1] = resource
    table.sort(Registry._ordered)
  end

  return normalized
end

function Registry.registerAddon(resource, descriptor)
  if type(resource) == 'table' and descriptor == nil then
    descriptor = resource
    resource = GetInvokingResource() or CORE
  end

  if type(descriptor) ~= 'table' then
    return { ok = false, error = 'descriptor must be a table' }
  end

  if type(resource) ~= 'string' or resource == '' then
    resource = GetInvokingResource() or CORE
  end

  local normalized = upsertAddon(resource, descriptor)
  return { ok = true, addon = cloneDescriptor(normalized) }
end

local function matchesCategory(addon, filter)
  if not filter or not filter.category then return true end
  local category = filter.category
  if type(category) == 'table' then
    for _, raw in ipairs(category) do
      if addon.category == sanitizeCategory(raw) then return true end
    end
    return false
  end
  return addon.category == sanitizeCategory(category)
end

local function matchesCapabilities(addon, filter)
  if not filter then return true end

  if filter.capability then
    local cap = sanitizeCapability(filter.capability)
    if not cap then return true end
    return addon._capabilityIndex[cap] == true
  end

  if filter.capabilities and type(filter.capabilities) == 'table' then
    for _, raw in ipairs(filter.capabilities) do
      local cap = sanitizeCapability(raw)
      if cap and not addon._capabilityIndex[cap] then
        return false
      end
    end
  end

  return true
end

local function matchesResource(addon, filter)
  if not filter or not filter.resource then return true end
  local resFilter = filter.resource
  if type(resFilter) == 'table' then
    for _, raw in ipairs(resFilter) do
      if addon.resource == raw then return true end
    end
    return false
  end
  return addon.resource == resFilter
end

function Registry.getRegisteredAddons(filter)
  local results = {}
  for _, resource in ipairs(Registry._ordered) do
    local addon = Registry._addons[resource]
    if addon and matchesCategory(addon, filter) and matchesCapabilities(addon, filter) and matchesResource(addon, filter) then
      results[#results+1] = cloneDescriptor(addon)
    end
  end
  return results
end

function Registry.getCategories()
  local results = {}
  for name, entry in pairs(Registry._categories) do
    results[#results+1] = {
      name = name,
      label = entry.label,
      description = entry.description,
      icon = entry.icon,
      createdAt = entry.createdAt,
    }
  end
  table.sort(results, function(a, b) return a.name < b.name end)
  return results
end

exports('RegisterAddon', function(resource, descriptor)
  return Registry.registerAddon(resource, descriptor)
end)

exports('GetRegisteredAddons', function(filter)
  return Registry.getRegisteredAddons(filter)
end)

return Registry
