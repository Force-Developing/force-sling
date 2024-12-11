fx_version "cerulean"
lua54 'yes'
game "gta5"

author 'Force Developments <discord:@force3883>'
description 'Sling for ESX, QBCore and custom frameworks'
version '1.0.0'

-- Dependencies
dependencies {
    'ox_lib',
}

-- Shared scripts
shared_scripts {
    '@ox_lib/init.lua',
    "config.lua",
}

-- Server scripts
server_scripts {
    'version.lua',

    "server/events.lua",
    "server/functions.lua",
    "server/misc/loader.lua",
    "server/main.lua",
    "server/custom/frameworks/*.lua",
    "server/custom/*.lua",
    "server/misc/*.lua"
}

-- Client scripts
client_scripts {
    "client/utils.lua",
    "client/events.lua",
    "client/functions.lua",
    "client/misc/loader.lua",
    "locales/*.lua",
    "client/main.lua",
    "client/callbacks.lua",
    "client/custom/frameworks/*.lua",
    "client/custom/*.lua",
    "client/misc/*.lua",
}
