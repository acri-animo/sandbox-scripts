fx_version 'cerulean'

name 'Lumen Gym'
description 'Gym script for fivem'
author 'Tiger'

version '1.0.0'
lua54 'yes'
game 'gta5'

client_script("@lumen-base/components/cl_error.lua")
client_script("@lumen-pwnzor/client/check.lua")

client_scripts {
    'client/**/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**/*.lua',
}

shared_script 'config.lua'
