fx_version 'cerulean'
name 'Lumen POS (Point of Sale)'
description 'POS script for fivem'
author 'Tiger'
version '1.0.0'
lua54 'yes'
game 'gta5'

ui_page('ui/build/index.html')

shared_script 'config.lua'

client_scripts {
    'client/**/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**/*.lua',
}

files {
    'ui/build/index.html',
    'ui/build/assets/*.css',
    'ui/build/assets/*.js',
}