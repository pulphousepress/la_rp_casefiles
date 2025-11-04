fx_version 'cerulean'
game 'gta5'

author 'Los Animales RP'
description 'NPC zone controller with MySQL whitelist + JSON fallback'
version '1.3.1'

shared_script '@ox_lib/init.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/main.lua'
}

client_scripts {
    'config.lua',
    'client/main.lua'
}

lua54 'yes'
