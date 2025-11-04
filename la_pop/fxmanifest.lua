fx_version 'cerulean'
game 'gta5'

author 'Pulphouse Press'
description 'Los Animales RP – Unified Population System (Density + Living NPCs + Patrols)'

shared_script 'config.lua'

client_scripts {
    'client/world_density.lua',
    'client/npc_manager.lua',
    'client/main.lua'
}

server_script 'server/main.lua'

files { 'stream/**/*.ymap' }

lua54 'yes'
