fx_version "cerulean"
lua54 'yes'
game "gta5"

author 'Force Developments <discord:@force3883>'
description 'Fivem Sling system for ESX, QBCore and custom frameworks'
version '1.0.0'

-- Dependencies
dependencies {
    'ox_lib',
}

-- Shared scripts
shared_scripts {
    '@ox_lib/init.lua', -- Initialization script for ox_lib
    "config.lua",       -- Configuration file
}

-- Server scripts
server_scripts {
    'version.lua',            -- Version control script

    "server/events.lua",      -- Server-side event handlers
    "server/functions.lua",   -- Server-side functions
    "server/misc/loader.lua", -- Miscellaneous loader script
    "server/main.lua",        -- Main server script
    "server/custom/*.lua",    -- Other custom server scripts
    "server/misc/*.lua"       -- Miscellaneous server scripts
}

-- Client scripts
client_scripts {
    "client/utils.lua",               -- Client-side utility functions
    "client/events.lua",              -- Client-side event handlers
    "client/functions.lua",           -- Client-side functions
    "client/misc/loader.lua",         -- Miscellaneous loader script
    "client/main.lua",                -- Main client script
    "client/callbacks.lua",           -- Client-side callback handlers
    "client/custom/frameworks/*.lua", -- Custom framework scripts
    "client/custom/*.lua",            -- Other custom client scripts
    "client/misc/*.lua",              -- Miscellaneous client scripts
}

-- Files to be included
files {
    "locales/*.json", -- Localization files
}
