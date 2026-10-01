function IsResourceStartingOrStarted(resource)
  return GetResourceState(resource) == "starting" or GetResourceState(resource) == "started"
end

function Debug(level, message, ...)
  if not Config.Debug then return end

  local levels = {
    error = function(msg) lib.print.error(msg) end,
    warn = function(msg) lib.print.warn(msg) end,
    info = function(msg) lib.print.info(msg) end,
    debug = function(msg) lib.print.debug(msg) end
  }

  local fn = levels[level] or levels.info
  fn(string.format(message, ...))
end

--- Addon weapons are often added with uppercase keys ("WEAPON_M4") or string names/models.
--- Inventories are matched in lowercase and GetSelectedPedWeapon returns hashes, so normalize once.
function NormalizeWeaponConfig()
  local weapons = {}
  for key, weapon in pairs(Config.Weapons) do
    local name = weapon.name or key
    weapons[key:lower()] = {
      model = type(weapon.model) == "string" and GetHashKey(weapon.model) or weapon.model,
      name = type(name) == "string" and GetHashKey(name) or name,
    }
  end
  Config.Weapons = weapons
end

--- Loads the configured locale. "auto" follows the replicated ox:locale convar (setr ox:locale "sv").
--- Region codes such as "pt-BR" fall back to "pt", and anything without a locale file to "en".
function InitLocale()
  local key = Config.Locale
  if type(key) ~= "string" or key == "auto" then
    key = GetConvar("ox:locale", "en")
  end

  local resource = GetCurrentResourceName()
  local function hasLocale(name)
    return name and LoadResourceFile(resource, ("locales/%s.json"):format(name)) ~= nil
  end

  if not hasLocale(key) then
    local language = key:match("^(%a+)")
    key = hasLocale(language) and language or "en"
  end

  lib.locale(key)
end

function InitFramework()
  if Config.Framework.name ~= "auto" then return end
  local frameworks = {
    { name = "esx",    resource = "es_extended" },
    { name = "qbx",    resource = "qbx_core" },
    { name = "qbcore", resource = "qb-core" }
  }

  Debug("info", "Initializing framework")
  for _, framework in ipairs(frameworks) do
    if IsResourceStartingOrStarted(framework.resource) then
      Config.Framework = framework
      Debug("info", "Framework initialized: " .. framework.name)
      return
    end
  end

  Config.Framework.name = "custom"
  lib.print.warn("No supported framework (es_extended, qbx_core, qb-core) is started, falling back to \"custom\". " ..
    "Start force-sling after your framework or set Config.Framework.name and edit client/custom/frameworks/custom.lua.")
end

function InitInventory()
  if Config.Inventory ~= "auto" then return end
  local inventories = {
    { name = "qs-inventory",   resource = "qs-inventory" },
    { name = "core_inventory", resource = "core_inventory" },
    { name = "qb-inventory",   resource = "qb-inventory" },
    { name = "ox_inventory",   resource = "ox_inventory" },
    { name = "tgiann-inventory", resource = "tgiann-inventory" }
  }

  Debug("info", "Initializing inventory")
  for _, inventory in ipairs(inventories) do
    if IsResourceStartingOrStarted(inventory.resource) then
      Config.Inventory = inventory.name
      Debug("info", "Inventory initialized: " .. Config.Inventory)
      return
    end
  end
  Config.Inventory = "none"
  Debug("info", "Inventory initialized: " .. Config.Inventory)
end
