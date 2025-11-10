fx_version 'cerulean'
game 'gta5'

name 'la_engine'
description 'Los Animales RP runtime gameplay layer'

lua54 'yes'

dependency 'ox_lib'
dependency 'la_core'

shared_script 'config.lua'

server_scripts {
    'server/main.lua',
    'server/weather_controller.lua',
    'server/era_vehicles.lua',
    'server/ped_gate.lua'
}

server_exports {
    'GetAllowedVehicleModels',
    'IsVehicleAllowed',
    'IsPedAllowed'
}

client_scripts {
    'client/main.lua',
    'client/modules/weather.lua'
}
