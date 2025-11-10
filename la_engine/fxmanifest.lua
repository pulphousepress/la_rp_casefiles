fx_version 'cerulean'
game 'gta5'

description 'Los Animales Engine runtime scaffold'

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
    'client/init.lua'
}

server_scripts {
    'server/main.lua',
    'server/init.lua'
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
