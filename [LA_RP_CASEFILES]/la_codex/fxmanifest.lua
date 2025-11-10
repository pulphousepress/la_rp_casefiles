fx_version 'cerulean'
game 'gta5'

name 'la_codex'
description 'Los Animales RP codex — shared data accessors'

lua54 'yes'

server_script 'server/main.lua'

server_exports {
    'GetCodexData',
    'GetVehicleByModel',
    'GetPedByModel',
    'GetFactionById'
}
