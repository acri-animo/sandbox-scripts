name('Lumen Petty Crime')
author('Tiger')
version('1.0.0')

lua54 'yes'
fx_version 'cerulean'
game 'gta5'

client_scripts {
    'client/**/*.lua',
}

server_scripts {
    'server/**/*.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
}