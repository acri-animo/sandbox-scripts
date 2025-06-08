fx_version("cerulean")
games({ "gta5" })
lua54("yes")

client_script("@lumen-base/components/cl_error.lua")
client_script("@lumen-pwnzor/client/check.lua")
server_script("@oxmysql/lib/MySQL.lua")

shared_scripts({
	"shared/**/*.lua",
	"shared/config.lua",
})

client_scripts({
	"@lumen-damage/shared/weapons.lua",
	"client/**/*.lua",
})

server_scripts({
	"server/**/*.lua",
})
