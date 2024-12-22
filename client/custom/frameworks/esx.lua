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
  item = item:lower()
  for k, v in pairs(Config.Weapons) do
    k = k:lower()
    if item == k then
      if Sling.cachedAttachments[item] then
        if DoesEntityExist(Sling.cachedAttachments[item].obj) or DoesEntityExist(Sling.cachedAttachments[item].placeholder) then
          DeleteEntity(Sling.cachedAttachments[item].obj)
          NetworkUnregisterNetworkedEntity(Sling.cachedAttachments[item].obj)
          DeleteObject(Sling.cachedAttachments[item].obj)
          DetachEntity(Sling.cachedAttachments[item].placeholder, true, false)
          DeleteObject(Sling.cachedAttachments[item].placeholder)
          Sling.currentAttachedAmount = Sling.currentAttachedAmount - 1
        end
      end
      Sling.cachedWeapons[item] = nil
      break;
    end
  end
end)
