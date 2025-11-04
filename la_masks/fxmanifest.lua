fx_version 'cerulean'
game 'gta5'

author 'Los Animales RP'
description 'Animal masks utility (apply/cycle masks on player)'
version '1.0.0'

shared_script 'config.lua'

client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    'data/masks_catalog.json',
    'data/mask_variants.json'
}
