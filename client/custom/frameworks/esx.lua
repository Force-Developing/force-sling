if Config.Framework.name ~= "esx" then
  return;
end

ESX = exports[(Config.Framework.resource == "auto" and "es_extended" or Config.Framework.resource)]:getSharedObject();

Framework = {};

function IsPlayerLoaded()
  return ESX.IsPlayerLoaded();
end

RegisterNetEvent("esx:addInventoryItem")
AddEventHandler("esx:addInventoryItem", function(item)
  item = item:lower()
  for k, v in pairs(Config.Weapons) do
    if item == k then
      Sling.cachedWeapons[item] = v
      Sling.cachedWeapons[item].attachments = Inventory:GetWeaponAttachment(item)
      break;
    end
  end
end)

RegisterNetEvent("esx:removeInventoryItem")
AddEventHandler("esx:removeInventoryItem", function(item)
  -- WeaponThread removes the prop once the weapon is gone from cachedWeapons
  Sling.cachedWeapons[item:lower()] = nil
end)
