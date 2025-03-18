fx_version 'cerulean'
game 'gta5'
lua54 "yes"


author 'Babun & Tech'
name 'Hud'
description 'Fivem Clean Status Hud'
version '1.0.0'

client_scripts {
    'config.lua',
    'client.lua'
}


server_script 'server.lua'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/js/*.js',
    'ui/css/*.css',
    'ui/fonts/*',
	'ui/images/*.png'
}
