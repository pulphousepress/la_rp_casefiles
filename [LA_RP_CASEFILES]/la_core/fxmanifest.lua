fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script 'config.lua'

server_scripts {
  'server/main.lua',
  'server/exports.lua',
  'server/la_status.lua'
}
client_scripts { 'client/main.lua' }

server_exports {
  'GetData',
  'GetVersion',
  'PrintStatus',
  'GetVehicleList',
  'GetPedList',
  'GetFactionList',
  'FindVehicle',
  'GetStatusSnapshot'
}
