fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Los Animales — Admin hub + addon registry'
author 'Los Animales RP'

dependency 'la_core'
dependency 'la_engine'

shared_script 'config.lua'

server_scripts {
  'server/main.lua',
  'server/addons_registry.lua',
  'server/commands.lua'
}

client_scripts {
  'client/main.lua',
  'client/ui_fallback.lua',
  'addons/**/client.lua'   -- optional per-addon clients
}

ui_page 'web/index.html'   -- simple placeholder UI (optional)

files {
  'web/index.html'
}

exports {
  'RegisterAddon',
  'GetRegisteredAddons',
  'GetAddonsByCapability'
}
