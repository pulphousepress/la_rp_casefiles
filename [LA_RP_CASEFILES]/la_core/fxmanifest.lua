fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script 'config.lua'

server_scripts {
  'server/main.lua'
}

client_scripts {
  'client/main.lua'
}

files {
  'web/index.html',
  'web/style.css'
}

server_exports { 'GetData', 'GetVersion', 'PrintStatus' }
