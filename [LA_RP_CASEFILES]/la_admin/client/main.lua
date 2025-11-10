local PANEL = { open = false }

local function toggle()
  PANEL.open = not PANEL.open
  if PANEL.open then
    TriggerEvent('chat:addMessage', { args = { '^2la_admin', 'Admin panel open — future NUI pending.' } })
  else
    TriggerEvent('chat:addMessage', { args = { '^2la_admin', 'Admin panel closed.' } })
  end
end

-- keybind
RegisterKeyMapping('la_admin_toggle', 'Toggle LA Admin', 'keyboard', Config.ToggleKey or 'F10')
RegisterCommand('la_admin_toggle', toggle, false)

-- chat fallback
RegisterCommand(Config.Command or 'la_admin', toggle, false)

CreateThread(function()
  if Config.Debug then print('[la_admin] client ready (stub UI)') end
end)
