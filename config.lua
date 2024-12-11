Config = {}

-- Enable or disable debug mode
-- @field [boolean] Debug - Set to true to enable debug mode, false to disable
Config.Debug = true

-- Set the locale for the application
-- @field [string] Locale - Language code for the locale ("ar", "en", "es", "fr", "pt", "de", "nl", "pl", "ru", "sv" or "auto")
Config.Locale = "en"

-- Admin configuration settings
-- @field [table] Admin - Configuration for admin settings
-- @field [table] Admin.Global - Global admin settings
-- @field [boolean] Admin.Global.enabled - Enable or disable global admin commands
-- @field [table] Admin.Global.players - List of player identifiers with admin access
Config.Admin = {
  Global = {
    enabled = true,
    players = {
      "discord:453870580374962177", -- Force
      "discord:566930948986241024", -- Olpis
    }
  }
}

-- Framework configuration settings
-- @field [table] Framework - Configuration for the framework
-- @field [string] Framework.name - Name of the framework ("esx", "qbcore", "custom" or "auto")
-- @field [string] Framework.resource - Resource name for ESX or QBCore
Config.Framework = {
  name = "auto",
  resource = "es_extended"
}

-- Inventory configuration settings
-- @field [string] Inventory - Inventory system to use ("none", "auto", "qs-inventory", "qb-inventory", "core_inventory", "ox_inventory" or "custom")
-- @field [boolean] UseWeaponAttachments - Enable or disable weapon attachments (may not work with all inventory systems and may lower performance)
Config.Inventory = "auto"
Config.UseWeaponAttachments = true

-- Command configuration settings
-- @field [table] Command - Configuration for the sling command
-- @field [string] Command.name - Name of the command
-- @field [string] Command.description - Description of the command
-- @field [string] Command.permission - Permission level required to use the command ("any" or specific permission)
Config.Command = {
  name = "sling",
  description = "Configure weapon positions",
  permission = "any"
}

-- Preset command configuration settings
-- @field [table] Presets - Configuration for the sling preset command
-- @field [string] Presets.command - Name of the preset command
-- @field [string] Presets.permission - Permission level required to use the preset command ("global" or specific permission)
Config.Presets = {
  command = "slingpreset",
  permission = "global"
}

-- Bone configuration settings
-- @field [table] Bones - Configuration for weapon attachment bones
-- @field [number] Bones.Back - Bone ID for back attachment
-- @field [number] Bones.Front - Bone ID for front attachment
Config.Bones = {
  ["Back"] = 24816,
  ["Front"] = 10706
}

-- Editable weapon configuration settings
-- @field [table] Weapons - Configuration for editable weapons
-- @field [table] Weapons[weapon_name] - Configuration for a specific weapon
-- @field [string] Weapons[weapon_name].model - Model name for the weapon
-- @field [string] Weapons[weapon_name].name - Internal name for the weapon
Config.Weapons = {
  ["weapon_pistol50"] = { model = `w_pi_pistol50`, name = `weapon_pistol50` },
  ["weapon_pistol"] = { model = `w_pi_pistol`, name = `weapon_pistol` },
  ["weapon_advancedrifle"] = { model = `w_ar_advancedrifle`, name = `weapon_advancedrifle` },
  ["weapon_assaultrifle"] = { model = `w_ar_assaultrifle`, name = `weapon_assaultrifle` },
  ["weapon_assaultrifle_mk2"] = { model = `w_ar_assaultriflemk2`, name = `weapon_assaultrifle_mk2` },
  ["weapon_assaultshotgun"] = { model = `w_sg_assaultshotgun`, name = `weapon_assaultshotgun` },
  ["weapon_assaultsmg"] = { model = `w_sb_assaultsmg`, name = `weapon_assaultsmg` },
  ["weapon_bullpuprifle"] = { model = `w_ar_bullpuprifle`, name = `weapon_bullpuprifle` },
  ["weapon_bullpuprifle_mk2"] = { model = `w_ar_bullpupriflemk2`, name = `weapon_bullpuprifle_mk2` },
  ["weapon_bullpupshotgun"] = { model = `w_sg_bullpupshotgun`, name = `weapon_bullpupshotgun` },
  ["weapon_carbinerifle"] = { model = `w_ar_carbinerifle`, name = `weapon_carbinerifle` },
  ["weapon_carbinerifle_mk2"] = { model = `w_ar_carbineriflemk2`, name = `weapon_carbinerifle_mk2` },
  ["weapon_combatmg"] = { model = `w_mg_combatmg`, name = `weapon_combatmg` },
  ["weapon_combatmg_mk2"] = { model = `w_mg_combatmgmk2`, name = `weapon_combatmg_mk2` },
  ["weapon_combatpdw"] = { model = `w_sb_pdw`, name = `weapon_combatpdw` },
  ["weapon_combatshotgun"] = { model = `w_sg_pumpshotgunh4`, name = `weapon_combatshotgun` },
  ["weapon_compactrifle"] = { model = `w_ar_assaultrifle_smg`, name = `weapon_compactrifle` },
  ["weapon_dbshotgun"] = { model = `w_sg_doublebarrel`, name = `weapon_dbshotgun` },
  ["weapon_firework"] = { model = `w_lr_firework`, name = `weapon_firework` },
  ["weapon_gusenberg"] = { model = `w_sb_gusenberg`, name = `weapon_gusenberg` },
  ["weapon_heavyrifle"] = { model = `w_ar_heavyrifleh`, name = `weapon_heavyrifle` },
  ["weapon_heavyshotgun"] = { model = `w_sg_heavyshotgun`, name = `weapon_heavyshotgun` },
  ["weapon_heavysniper"] = { model = `w_sr_heavysniper`, name = `weapon_heavysniper` },
  ["weapon_heavysniper_mk2"] = { model = `w_sr_heavysnipermk2`, name = `weapon_heavysniper_mk2` },
  ["weapon_marksmanrifle"] = { model = `w_sr_marksmanrifle`, name = `weapon_marksmanrifle` },
  ["weapon_marksmanrifle_mk2"] = { model = `w_sr_marksmanriflemk2`, name = `weapon_marksmanrifle_mk2` },
  ["weapon_mg"] = { model = `w_mg_mg`, name = `weapon_mg` },
  ["weapon_microsmg"] = { model = `w_sb_microsmg`, name = `weapon_microsmg` },
  ["weapon_militaryrifle"] = { model = `w_ar_bullpuprifleh4`, name = `weapon_militaryrifle` },
  ["weapon_minismg"] = { model = `w_sb_minismg`, name = `weapon_minismg` },
  ["weapon_musket"] = { model = `w_ar_musket`, name = `weapon_musket` },
  ["weapon_pumpshotgun"] = { model = `w_sg_pumpshotgun`, name = `weapon_pumpshotgun` },
  ["weapon_pumpshotgun_mk2"] = { model = `w_sg_pumpshotgunmk2`, name = `weapon_pumpshotgun_mk2` },
  ["weapon_sawnoffshotgun"] = { model = `w_sg_sawnoff`, name = `weapon_sawnoffshotgun` },
  ["weapon_smg"] = { model = `w_sb_smg`, name = `weapon_smg` },
  ["weapon_smg_mk2"] = { model = `w_sb_smgmk2`, name = `weapon_smg_mk2` },
  ["weapon_sniperrifle"] = { model = `w_sr_sniperrifle`, name = `weapon_sniperrifle` },
  ["weapon_specialcarbine"] = { model = `w_ar_specialcarbine`, name = `weapon_specialcarbine` },
  ["weapon_specialcarbine_mk2"] = { model = `w_ar_specialcarbinemk2`, name = `weapon_specialcarbine_mk2` },
  ["weapon_autoshotgun"] = { model = `w_sg_sweeper`, name = `weapon_autoshotgun` },
  ["weapon_precisionrifle"] = { model = `w_sr_precisionrifle_reh`, name = `weapon_precisionrifle` },
  ["weapon_tacticalrifle"] = { model = `w_ar_carbinerifle_reh`, name = `weapon_tacticalrifle` },
  ["weapon_rayminigun"] = { model = `w_mg_sminigun`, name = `weapon_rayminigun` },
  ["weapon_raycarbine"] = { model = `w_ar_srifle`, name = `weapon_raycarbine` },
  ["weapon_railgun"] = { model = `w_ar_railgun`, name = `weapon_railgun` },
  ["weapon_rpg"] = { model = `w_lr_rpg`, name = `weapon_rpg` },
  ["weapon_hominglauncher"] = { model = `w_lr_homing`, name = `weapon_hominglauncher` },
  ["weapon_minigun"] = { model = `w_mg_minigun`, name = `weapon_minigun` },
  ["weapon_bat"] = { model = `w_me_bat`, name = `weapon_bat` },
  ["weapon_battleaxe"] = { model = `w_me_battleaxe`, name = `weapon_battleaxe` },
  ["weapon_crowbar"] = { model = `w_me_crowbar`, name = `weapon_crowbar` },
  ["weapon_fireextinguisher"] = { model = `w_am_fire_exting`, name = `weapon_fireextinguisher` },
  ["weapon_golfclub"] = { model = `w_me_gclub`, name = `weapon_golfclub` },
  ["weapon_hatchet"] = { model = `w_me_hatchet`, name = `weapon_hatchet` },
  ["weapon_hazardcan"] = { model = `w_ch_jerrycan`, name = `weapon_hazardcan` },
  ["weapon_fertilizercan"] = { model = `w_am_jerrycan_sf`, name = `weapon_fertilizercan` },
  ["weapon_machete"] = { model = `w_me_machette_lr`, name = `weapon_machete` },
  ["weapon_nightstick"] = { model = `w_me_nightstick`, name = `weapon_nightstick` },
  ["weapon_petrolcan"] = { model = `w_am_jerrycan`, name = `weapon_petrolcan` },
  ["weapon_poolcue"] = { model = `w_me_poolcue`, name = `weapon_poolcue` },
  ["weapon_stone_hatchet"] = { model = `w_me_stonehatchet`, name = `weapon_stone_hatchet` },
  ["weapon_wrench"] = { model = `w_me_wrench`, name = `weapon_wrench` },
  ["weapon_candycane"] = { model = `w_me_candy_xm3`, name = `weapon_candycane` },
}
