-- la_core/server/commands.lua — operator commands facade
local Commands = {}
local registered = false

local function ensureLogger(ctx, level, message)
  if type(ctx.logger) == 'function' then
    ctx.logger(level, message)
  else
    print(string.format('[la_core][%s] %s', level, message))
  end
end

local function encode(value)
  if type(json) == 'table' and json.encode then
    local ok, payload = pcall(json.encode, value)
    if ok then return payload end
  end
  return nil
end

local function logAction(ctx, source, commandName, details)
  local actor = (source == 0) and 'console' or ('player:' .. tostring(source))
  local suffix = ''
  if details then
    local payload = encode(details)
    if payload and payload ~= 'null' then
      suffix = ' ' .. payload
    end
  end
  ensureLogger(ctx, 'info', string.format('command %s invoked %s%s', actor, commandName, suffix))
end

local function respond(source, lines)
  if source == 0 then
    for _, line in ipairs(lines) do print(line) end
    return
  end

  for _, line in ipairs(lines) do
    TriggerClientEvent('chat:addMessage', source, { args = { 'LA', line } })
  end
end

local function trim(value)
  if type(value) ~= 'string' then return '' end
  return value:match('^%s*(.-)%s*$')
end

local function splitCSV(text)
  local out = {}
  for token in string.gmatch(text, '([^,]+)') do
    token = trim(token)
    if token ~= '' then
      out[#out+1] = token
    end
  end
  return out
end

local function parseFilters(args)
  local filters = {}
  if type(args) ~= 'table' then return filters end

  for _, raw in ipairs(args) do
    raw = trim(raw)
    if raw ~= '' then
      local key, value = raw:match('^(%w+):(.*)$')
      if key and value then
        key = key:lower()
        value = trim(value)
        if key == 'cap' or key == 'capability' then
          filters.capability = value
        elseif key == 'caps' or key == 'capabilities' then
          filters.capabilities = splitCSV(value)
        elseif key == 'category' or key == 'cat' then
          filters.category = value
        elseif key == 'resource' or key == 'res' then
          filters.resource = value
        end
      else
        filters.capability = raw
      end
    end
  end

  return filters
end

local function formatStatusLine(status)
  if not status then return 'core status unavailable' end
  if status.ok then
    local manifest = status.manifestVersion or 'unknown'
    return string.format('core %s ok (codex=%s, manifest=%s)', status.version or 'n/a', status.codex or 'n/a', manifest)
  end
  return 'core status check failed (see server logs)'
end

local function formatAddon(addon)
  local caps = addon.capabilities or {}
  local capsText = (#caps > 0) and table.concat(caps, ', ') or 'none'
  local label = addon.name or addon.resource or 'unknown'
  local category = addon.category or 'misc'
  local version = addon.version or '0.0.0'
  local description = addon.description or ''
  if description ~= '' then
    return string.format('[%s] %s v%s — %s (caps: %s)', category, label, version, description, capsText)
  end
  return string.format('[%s] %s v%s (caps: %s)', category, label, version, capsText)
end

function Commands.register(ctx)
  if registered then return end
  registered = true

  ctx = ctx or {}
  local statusCommand = ctx.statusCommand or 'la_status'
  local addonsCommand = ctx.addonsCommand or 'la_addons'
  local registry = ctx.registry
  local getStatus = ctx.getStatus or function() return { ok = false } end

  RegisterCommand(statusCommand, function(source)
    local status = getStatus()
    logAction(ctx, source, '/' .. statusCommand, status)
    respond(source, { formatStatusLine(status) })
  end, false)

  RegisterCommand(addonsCommand, function(source, args)
    local filters = parseFilters(args)
    logAction(ctx, source, '/' .. addonsCommand, filters)

    local lines = {}
    if not registry or type(registry.getRegisteredAddons) ~= 'function' then
      lines[1] = 'addon registry unavailable'
      respond(source, lines)
      return
    end

    local addons = registry.getRegisteredAddons(filters)
    if #addons == 0 then
      lines[1] = 'no addons registered'
    else
      lines[1] = string.format('addons: %d result(s)', #addons)
      for i = 1, #addons do
        lines[#lines+1] = formatAddon(addons[i])
      end
    end

    respond(source, lines)
  end, false)

  ensureLogger(ctx, 'info', string.format('commands ready (%s, %s)', '/' .. statusCommand, '/' .. addonsCommand))

  return {
    status = statusCommand,
    addons = addonsCommand,
  }
end

return Commands
