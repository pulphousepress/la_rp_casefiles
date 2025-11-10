-- la_core/client/main.lua — lightweight stub for future NUI work
local function dbg(msg)
  if Config and Config.Debug then
    print('[la_core][client] ' .. msg)
  end
end

local Client = {
  ready = false,
  nui = {
    loaded = false,
  },
}

function Client.getStatus()
  return {
    ready = Client.ready,
    nui = Client.nui,
    version = Config and Config.Version or '0.0.0',
  }
end

CreateThread(function()
  Wait(250)
  Client.ready = true
  dbg('client stub initialized (NUI bootstrap pending)')
end)

LA_CORE_CLIENT = Client
