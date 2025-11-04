fx_version 'cerulean'
game 'gta5'

author 'Los Animales RP'
description 'Admin Dispatch Console (Alpha Build)'
version '1.2.0'

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
    'client/init.lua'
}

server_scripts {
    'server/main.lua',
    'server/init.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/main.js',
    'html/img/*.png'
}
