fx_version 'cerulean'
game 'gta5'

author 'You'
description 'Los Animales - Diegetic radio'
version '1.0.0'

-- Lua
client_script 'client/main.lua'
server_script 'server/main.lua'

-- NUI
ui_page 'html/index.html'

files {
  -- NUI
  'html/index.html',
  'html/*.css',
  'html/*.js',
  'html/img/*',
  -- Broadcast content
  'broadcast/**/*',
  -- Extra test/static files
  'broadcast/extra/*'
}
