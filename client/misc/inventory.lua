Inventory = {}

local function SafeInventoryCall(fn)
  local success, result = pcall(fn)
  if not success then
    Debug("error", "Inventory error: " .. tostring(result))
    return nil
  end
  return result
end

--- Retrieves the player's slingable weapons from the inventory.
--- @param userInventory table|nil Inventory items; fetched when omitted
--- @return table A table containing the player's weapons, keyed by lowercase weapon name.
function Inventory:GetWeapons(userInventory)
  local weapons = {}
  userInventory = userInventory or self:GetUserInventory()

  if not userInventory then
    return weapons
  end

  for _, v in pairs(userInventory) do
    local itemName = v and v.name and v.name:lower()
    local weapon = itemName and Config.Weapons[itemName]
    if weapon then
      weapons[itemName] = weapon
      weapon.attachments = self:GetWeaponAttachment(itemName, userInventory)
    end
  end

  return weapons
end

local oxComponentHashes = {}

--- ox_inventory stores attachments as component item names (metadata.components = { "at_flashlight" }).
--- The item's client.component lists one hash per weapon family; pick the one this weapon accepts.
--- @return number|nil
local function GetOxComponentHash(componentName, weaponHash)
  local hashes = oxComponentHashes[componentName]
  if hashes == nil then
    local ok, itemData = pcall(function() return exports.ox_inventory:Items(componentName) end)
    hashes = ok and type(itemData) == "table" and type(itemData.client) == "table"
        and type(itemData.client.component) == "table" and itemData.client.component or false
    oxComponentHashes[componentName] = hashes
  end
  if not hashes or not weaponHash then return nil end

  for _, hash in ipairs(hashes) do
    if DoesWeaponTakeWeaponComponent(weaponHash, hash) then
      return hash
    end
  end
  return nil
end

--- Retrieves the attachments for a specific weapon.
--- @param item string The weapon name.
--- @param userInventory table|nil Inventory items; fetched when omitted
--- @return table A table containing the weapon's attachments.
function Inventory:GetWeaponAttachment(item, userInventory)
  if not Config.UseWeaponAttachments then return {} end
  local components = {}
  userInventory = userInventory or self:GetUserInventory()

  if Config.Inventory == "custom" then
    local custom = SafeInventoryCall(function() return CustomInventory:GetWeaponAttachment(item, userInventory) end)
    if custom then return custom end
  end

  if not userInventory then
    return components
  end

  item = item:lower()
  local weapon = Config.Weapons[item]
  for _, v in pairs(userInventory) do
    if v and v.name and v.name:lower() == item then
      if v.info and v.info.attachments then
        for _, attachment in pairs(v.info.attachments) do
          table.insert(components, attachment.component)
        end
      end

      local oxComponents = v.metadata and v.metadata.components
      if Config.Inventory == "ox_inventory" and type(oxComponents) == "table" then
        for _, componentName in ipairs(oxComponents) do
          local hash = GetOxComponentHash(componentName, weapon and weapon.name)
          if hash then table.insert(components, hash) end
        end
      end
    end
  end

  return components
end

--- Retrieves the user's inventory based on the configured inventory system.
--- @return table|nil The user's inventory or nil if it can't be read (weapons are then tracked through framework events).
function Inventory:GetUserInventory()
  if Config.Inventory == "qs-inventory" then
    return SafeInventoryCall(function() return exports['qs-inventory']:getUserInventory() end)
  elseif Config.Inventory == "core_inventory" then
    return SafeInventoryCall(function() return exports.core_inventory:getInventory() end)
  elseif Config.Inventory == "ox_inventory" then
    return SafeInventoryCall(function() return exports.ox_inventory:GetPlayerItems() end)
  elseif Config.Inventory == "tgiann-inventory" then
    return SafeInventoryCall(function() return exports['tgiann-inventory']:GetPlayerItems() end)
  elseif Config.Inventory == "custom" then
    return SafeInventoryCall(function() return CustomInventory:GetWeapons() end)
  elseif GetFrameworkItems then
    -- "none"/qb-inventory: items stored in the framework player data (QBCore/QBX items, ESX loadout)
    return SafeInventoryCall(GetFrameworkItems)
  end
  return nil
end
