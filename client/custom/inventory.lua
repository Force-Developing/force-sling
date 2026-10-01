if Config.Inventory ~= "custom" then return end
CustomInventory = {}

--- Returns the player's inventory items. Despite the name it returns every item, not only weapons:
--- the sling picks out the ones in Config.Weapons. Read every second.
--- @return table|nil A list of items with a .name field (e.g. { { name = "weapon_pistol", info = {...} } }),
--- or nil if you can't read the inventory and add/remove Sling.cachedWeapons through events instead.
--- Returning {} means "no items" and removes every slung weapon.
function CustomInventory:GetWeapons()
  -- TODO: return exports['my-inventory']:GetPlayerItems()
  return nil
end

--- Optional. Returns the weapon component hashes for a weapon item.
--- @param item string The lowercase weapon item name.
--- @param userInventory table|nil The items returned by GetWeapons.
--- @return table|nil A list of component hashes, or nil to use the default (item.info.attachments[].component).
function CustomInventory:GetWeaponAttachment(item, userInventory)
  return nil
end
