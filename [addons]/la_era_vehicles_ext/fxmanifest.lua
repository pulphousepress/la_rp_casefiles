fx_version 'cerulean'
game 'gta5'

name 'la_era_vehicles_ext'
description 'Los Animales RP era vehicle registry extension'

lua54 'yes'

-- This addon depends on the base admin/core/engine stacks so that it can
-- register itself and query vehicle data exports.
dependency 'la_admin'
dependency 'la_core'
dependency 'la_engine'

server_scripts {
    'server/main.lua'
}
