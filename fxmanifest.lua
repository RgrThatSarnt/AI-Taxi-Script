fx_version 'cerulean'
game 'gta5'

author 'Squeeze Studios'
description 'Standalone AI Taxi System'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
    'client/spawn.lua',
    'client/drive.lua',
    'client/waypoint.lua',
    'client/input.lua'
}

server_script 'server/main.lua'
