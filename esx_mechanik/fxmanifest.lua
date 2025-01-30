fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'QF Developers'
description 'esx_mechanik'
shared_scripts { 
	'@es_extended/imports.lua',
	'@esx_scriptHash/hasher.lua',
	'@ox_lib/init.lua',
	'config.lua',
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}