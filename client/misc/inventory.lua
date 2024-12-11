Inventory = {}

function Inventory:GetWeapons()
  local weapons = {};
  if Config.Inventory == "qs-inventory" then
    local userInventory = exports['qs-inventory']:getUserInventory()
    for _, v in pairs(userInventory) do
      for key, val in pairs(Config.Weapons) do
        if v.name == key then
          weapons[key] = val
          weapons[key].attachments = Inventory:GetWeaponAttachment(key)
          break;
        end
      end
    end
  elseif Config.Inventory == "core_inventory" then
    local userInventory = exports.core_inventory:getInventory()
    for _, v in pairs(userInventory) do
      for key, val in pairs(Config.Weapons) do
        if v.name == key then
          weapons[key] = val
          weapons[key].attachments = Inventory:GetWeaponAttachment(key)
          break;
        end
      end
    end
  end
  return weapons
end

function Inventory:GetWeaponAttachment(item)
  local components = {}

  if Config.Inventory == "qs-inventory" then
    local userInventory = exports['qs-inventory']:getUserInventory()
    for _, v in pairs(userInventory) do
      if v.name == item then
        for _, v3 in pairs(v.info.attachments) do
          table.insert(components, v3.component)
        end
      end
    end
  end

  return components
end
