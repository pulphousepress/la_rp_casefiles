fx_version 'cerulean'
game 'gta5'

name 'la_engine'
description 'Los Animales Engine - runtime gameplay systems'
version '1.0.0'

-- This resource depends on la_core for codex data.
dependencies { 'la_core' }

server_scripts {
  'config.lua',
  'server/main.lua'
}

client_scripts {
  'config.lua',
  'client/main.lua'
}