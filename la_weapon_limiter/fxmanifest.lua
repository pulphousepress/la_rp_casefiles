fx_version 'cerulean'
game 'gta5'

description 'Los Animales RP - Job-Based Weapon Restrictions'

shared_scripts {
    '@ph_shared/init.lua',
    'config.lua'
}

server_scripts {
    'la_weapon_limiter.lua',
    'server/init.lua'
}
server_script 'la_weapon_limiter.lua'

lua54 'yes'
