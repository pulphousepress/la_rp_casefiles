-- server/main.lua (CLEANED & DROP-IN)
-- Commands:
--   /la_radio_set <index|id>
--   /la_radio_forceplay <folder/file> [pos]
--   /la_radio_announce <message>
--
-- Configure admin access in Config.

local Config = {
  useAce = false,
  acePermission = "la_radio.admin",
  admins = {
    -- Example: ["steam:110000112345678"] = true,
  },
  broadcastBasePrefix = "../broadcast/"
}

local currentStation = nil

local function sendChat(src, msg)
  if src == 0 then
    print(("[la_radio] %s"):format(msg))
  else
    TriggerClientEvent("chat:addMessage", src, { args = { "^1la_radio", msg } })
  end
end

local function hasPermission(src)
  if src == 0 then return true end

  if Config.useAce and type(IsPlayerAceAllowed) == "function" then
    local ok, allowed = pcall(IsPlayerAceAllowed, src, Config.acePermission)
    if ok and allowed then return true end
  end

  local ids = GetPlayerIdentifiers(src) or {}
  for _, id in ipairs(ids) do
    if Config.admins[id] then
      return true
    end
  end

  return false
end

local function buildClientUrl(filePath)
  if not filePath or filePath == "" then return nil end
  if tostring(filePath):match("^%.%./broadcast/") then
    return filePath
  end
  return Config.broadcastBasePrefix .. filePath
end

-- /la_radio_set <index|id>
RegisterCommand("la_radio_set", function(src, args, raw)
  if not hasPermission(src) then
    sendChat(src, "You are not permitted to run this command.")
    return
  end

  if not args[1] then
    sendChat(src, "Usage: /la_radio_set <index|stationId>")
    return
  end

  local arg = args[1]
  local idx = tonumber(arg)
  currentStation = idx or arg

  local payload = {
    index = idx,
    id = (idx and nil) or arg,
    startTime = os.time()
  }

  TriggerClientEvent("la_radio:server_set_station", -1, payload)
  sendChat(src, ("Station set to %s (startTime=%s)"):format(tostring(currentStation), tostring(payload.startTime)))
  print(("la_radio: station set to %s by %s"):format(tostring(currentStation), tostring(src)))
end, false)

-- /la_radio_forceplay <folder/file> [pos]
RegisterCommand("la_radio_forceplay", function(src, args, raw)
  if not hasPermission(src) then
    sendChat(src, "You are not permitted to run this command.")
    return
  end

  if not args[1] then
    sendChat(src, "Usage: /la_radio_forceplay <folder/file.ogg> [position_seconds]")
    return
  end

  local filePath = args[1]
  local pos = tonumber(args[2]) or 0

  if not tostring(filePath):match(".+/.+%.%w+$") then
    sendChat(src, "Invalid file path. Expected <folder>/<file.ext> (e.g. radio_chnl_01/01_song.ogg)")
    return
  end

  local url = buildClientUrl(filePath)
  TriggerClientEvent("la_radio:server_sync_play", -1, { url = url, position = pos })
  sendChat(src, ("Forced play: %s @ %ss"):format(filePath, tostring(pos)))
  print(("la_radio: forceplay requested by %s -> %s @ %s"):format(tostring(src), tostring(url), tostring(pos)))
end, false)

-- /la_radio_announce <message>
RegisterCommand("la_radio_announce", function(src, args, raw)
  if not hasPermission(src) then
    sendChat(src, "You are not permitted to run this command.")
    return
  end

  if #args == 0 then
    sendChat(src, "Usage: /la_radio_announce <message>")
    return
  end

  local msg = table.concat(args, " ")
  TriggerClientEvent("chat:addMessage", -1, { args = { "^3LA Radio Announcement", msg } })
  print(("la_radio: announcement by %s -> %s"):format(tostring(src), msg))
end, false)

-- Optional export (example)
-- exports("SetLaRadioStation", function(indexOrId)
--   TriggerClientEvent("la_radio:server_set_station", -1, { index = tonumber(indexOrId), id = (type(indexOrId) == "string" and indexOrId or nil), startTime = os.time() })
-- end)

print("la_radio: server script loaded. Use /la_radio_set and /la_radio_forceplay to control stations.")
