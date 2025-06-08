fx_version("cerulean")
games({ "gta5" })
lua54("yes")

author("Tiger")
description("Lumen Taxi Job")

client_script("@lumen-base/components/cl_error.lua")
client_script("@lumen-pwnzor/client/check.lua")

shared_scripts({
	"config.lua",
})

client_scripts({
	"client/**/*.lua",
})

server_scripts({
	"server/**/*.lua",
	"@oxmysql/lib/MySQL.lua",
})