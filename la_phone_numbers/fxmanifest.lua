-- la_phone_numbers / fxmanifest.lua
-- Generates 1950s-style exchange phone numbers for Los Animales RP

fx_version 'cerulean'
game 'gta5'

author 'Pulphouse Press'
description 'Era-based phone number generator for NPWD_la'
version '1.0.0'

lua54 'yes'

-- Order matters: config first, then main logic
shared_script 'config.lua'
server_script 'server/main.lua'

-- Exported for NPWD_la integration
exports { 'GenerateEraPhoneNumber' }
