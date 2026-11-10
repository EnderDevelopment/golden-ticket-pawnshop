fx_version 'cerulean'
game 'gta5'

lua54 'yes'

name 'ender_pawnshop'
author 'EnderDevelopment'
description 'Configurable pawnshop with server-validated sales and NUI'
version '1.0.0'

ui_page 'html/index.html'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}
