fx_version 'cerulean'
game 'gta5'

author 'Pulphouse Press'
description 'Los Animales - Era Traffic System'
version '1.0.0'

-- Client & Server scripts
client_scripts {
    'client.lua'
}

server_scripts {
    'server/*.lua'
}

-- Shared config (loads into both client + server)
shared_scripts {
    'shared/config.lua'
}

-- Data files (popgroups etc.)
data_file 'DLC_POP_GROUPS' 'server/popgroups.ymt'
files {
    'server/popgroups.ymt'
}
