fx_version 'cerulean'
game 'gta5'

author 'Los Animales RP'
description 'NPC population controls for Los Animales RP'
version '1.4.1'

shared_scripts {
    '@ph_shared/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/init.lua'
}

server_scripts {
    'server/main.lua',
    'server/init.lua'
}

lua54 'yes'
