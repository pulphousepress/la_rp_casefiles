fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'la_weather'
author 'Pulphouse Press'
version 'v2.0.0'
description 'Zone-aware noir weather with Toontown sunny override, progressive north zones, dusk lock, and NUI monitor'

shared_script 'config.lua'
client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
