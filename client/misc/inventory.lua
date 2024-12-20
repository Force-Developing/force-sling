Inventory = {}

--- Retrieves the player's weapons from the inventory.
--- @return table A table containing the player's weapons.
function Inventory:GetWeapons()
  local weapons = {}
  local userInventory

  -- Check the configured inventory system and retrieve the user's inventory
  if Config.Inventory == "qs-inventory" then
    userInventory = exports['qs-inventory']:getUserInventory()
  elseif Config.Inventory == "core_inventory" then
    userInventory = exports.core_inventory:getInventory()
  elseif Config.Inventory == "qb-inventory" then
    userInventory = QBCore.Functions.GetPlayerData().items
  elseif Config.Inventory == "ox_inventory" then
    userInventory = exports.ox_inventory:GetPlayerItems()
  elseif Config.Inventory == "custom" then
    return CustomInventory:GetWeapons()
  else
    Sling:Debug("warn", "Unsupported inventory system: " .. tostring(Config.Inventory))
    return weapons
  end

  -- Iterate through the user's inventory and match weapons with the configured weapons
  for _, v in pairs(userInventory) do
    for key, val in pairs(Config.Weapons) do
      if v.name:lower() == key:lower() then
        weapons[key] = val
        weapons[key].attachments = Inventory:GetWeaponAttachment(key)
        Sling:Debug("info", "Weapon found: " .. key)
        break
      end
    end
  end

  return weapons
end

--- Retrieves the attachments for a specific weapon.
--- @param item string The weapon name.
--- @return table A table containing the weapon's attachments.
function Inventory:GetWeaponAttachment(item)
  if not Config.UseWeaponAttachments then return {} end
  local components = {}
  local userInventory

  -- Check the configured inventory system and retrieve the user's inventory
  if Config.Inventory == "qs-inventory" then
    userInventory = exports['qs-inventory']:getUserInventory()
  elseif Config.Inventory == "core_inventory" then
    userInventory = exports.core_inventory:getInventory()
  elseif Config.Inventory == "qb-inventory" then
    userInventory = QBCore.Functions.GetPlayerData().items
  elseif Config.Inventory == "ox_inventory" then
    userInventory = exports.ox_inventory:GetPlayerItems()
  elseif Config.Inventory == "custom" then
    return CustomInventory:GetWeaponAttachment(item)
  else
    Sling:Debug("warn", "Unsupported inventory system: " .. tostring(Config.Inventory))
    return components
  end

  -- Iterate through the user's inventory and match attachments with the specified weapon
  for _, v in pairs(userInventory) do
    if v.name:lower() == item:lower() and v.info and v.info.attachments then
      for _, attachment in pairs(v.info.attachments) do
        table.insert(components, attachment.component)
        Sling:Debug("info", "Attachment found for weapon: " .. item .. " component: " .. attachment.component)
      end
    end
  end

  return components
end
