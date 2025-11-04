-- resources/[ui]/loadscreen/fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

name 'Los Animales Loadscreen'
author 'Los Animales RP'
version '2.1.3'
description '1950s noir themed loadscreen'

lua54 'yes'
use_experimental_fxv2_oal 'yes'  -- lets you use server/*.js if needed

files {
  'html/index.html',
  'html/**/*',
  'html/assets/music/Noir_Detective.mp3'
}

-- native loadscreen keys (preferred over ui_page)
loadscreen 'html/index.html'
loadscreen_cursor 'yes'
loadscreen_manual_shutdown 'yes'

-- OPTIONAL: if you have a tiny client for manual shutdowns
client_scripts {
  -- 'client/shutdown.lua'
}

-- OPTIONAL: if you actually use a server handover script
server_scripts {
  -- 'server/handover.js'
}
