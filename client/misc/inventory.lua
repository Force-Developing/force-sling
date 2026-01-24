Inventory = {}

local function SafeInventoryCall(fn)
  local success, result = pcall(fn)
  if not success then
    Debug("error", "Inventory error: " .. tostring(result))
    return nil
  end
  return result
end

-- ox_inventory event handler for item count changes
AddEventHandler('ox_inventory:itemCount', function(itemName, count)
  if Config.Inventory ~= "ox_inventory" then return end

  local item = itemName:lower()

  -- Check if this item is a configured weapon
  for k, v in pairs(Config.Weapons) do
    if item == k:lower() then
      if count > 0 then
        -- Weapon was added to inventory
        Sling.cachedWeapons[item] = v
        Sling.cachedWeapons[item].attachments = Inventory:GetWeaponAttachment(item)
        Debug("info", "Weapon added to sling cache: " .. item)
      else
        -- Weapon was removed from inventory (dropped, sold, etc.)
        if Sling.cachedAttachments[item] then
          if DoesEntityExist(Sling.cachedAttachments[item].obj) or DoesEntityExist(Sling.cachedAttachments[item].placeholder) then
            DeleteEntity(Sling.cachedAttachments[item].obj)
            if NetworkGetEntityIsNetworked(Sling.cachedAttachments[item].obj) then
              NetworkUnregisterNetworkedEntity(Sling.cachedAttachments[item].obj)
            end
            DeleteObject(Sling.cachedAttachments[item].obj)
            DetachEntity(Sling.cachedAttachments[item].placeholder, true, false)
            DeleteObject(Sling.cachedAttachments[item].placeholder)
            Sling.currentAttachedAmount = Sling.currentAttachedAmount - 1
          end
          Sling.cachedAttachments[item] = nil
        end
        Sling.cachedWeapons[item] = nil
        Debug("info", "Weapon removed from sling cache: " .. item)
      end
      break
    end
  end
end)

--- Retrieves the player's weapons from the inventory.
--- @return table A table containing the player's weapons.
function Inventory:GetWeapons()
  local weapons = {}
  local userInventory = self:GetUserInventory()

  if not userInventory then
    Debug("warn", "Unsupported inventory system: " .. tostring(Config.Inventory))
    return weapons
  end

  -- Iterate through the user's inventory and match weapons with the configured weapons
  for _, v in pairs(userInventory) do
    for key, val in pairs(Config.Weapons) do
      if v.name:lower() == key:lower() then
        weapons[key] = val
        weapons[key].attachments = self:GetWeaponAttachment(key)
        Debug("info", "Weapon found: " .. key)
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
  local userInventory = self:GetUserInventory()

  if not userInventory then
    Debug("warn", "Unsupported inventory system: " .. tostring(Config.Inventory))
    return components
  end

  -- Iterate through the user's inventory and match attachments with the specified weapon
  for _, v in pairs(userInventory) do
    if v.name:lower() == item:lower() and v.info and v.info.attachments then
      for _, attachment in pairs(v.info.attachments) do
        table.insert(components, attachment.component)
        Debug("info", "Attachment found for weapon: " .. item .. " component: " .. attachment?.component)
      end
    end
  end

  return components
end

--- Retrieves the user's inventory based on the configured inventory system.
--- @return table|nil The user's inventory or nil if the inventory system is unsupported.
function Inventory:GetUserInventory()
  if Config.Inventory == "qs-inventory" then
    return SafeInventoryCall(function() return exports['qs-inventory']:getUserInventory() end)
  elseif Config.Inventory == "core_inventory" then
    return SafeInventoryCall(function() return exports.core_inventory:getInventory() end)
  elseif Config.Inventory == "qb-inventory" then
    return QBCore.Functions.GetPlayerData().items
  elseif Config.Inventory == "ox_inventory" then
    return exports.ox_inventory:GetPlayerItems()
  elseif Config.Inventory == "custom" then
    return CustomInventory:GetWeapons()
  elseif Config.Inventory == "tgiann-inventory" then
    return SafeInventoryCall(function() return exports['tgiann-inventory']:GetPlayerItems() end)
  else
    return nil
  end
end
