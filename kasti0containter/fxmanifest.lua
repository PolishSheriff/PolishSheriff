fx_version 'cerulean'
game 'gta5'

author 'PiFordzikk'
description 'Conte4ners'
version '1.0.0'

shared_script '@ox_lib/init.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_target',
    'ox_inventory',
    'glow_minigames'
}
