if Config.Framework.name ~= "qbx" then
  return;
end

local isPlayerLoaded = false;

-- Extremely unomptimized since qbcore's inventory system dosen't have a way to check when a new item is added to my knowledge
CreateThread(function()
  while not LocalPlayer.state.isLoggedIn and not isPlayerLoaded do
    Wait(100)
  end
  isPlayerLoaded = true;
  while true do
    local xPlayer = exports.qbx_core:GetPlayerData()
    if not xPlayer or not xPlayer.items then
      Wait(1000);
    end
    local cachedItems = {}
    for _, v in pairs(xPlayer.items) do
      for key, val in pairs(Config.Weapons) do
        key = key:lower()
        v.name = v.name:lower()
        if v.name == key then
          cachedItems[key] = true
          Sling.cachedWeapons[key] = val
          Sling.cachedWeapons[key].attachments = Inventory:GetWeaponAttachment(key)
          break
        end
      end
    end
    for key, val in pairs(Config.Weapons) do
      key = key:lower()
      if not cachedItems[key] then
        if Sling.cachedAttachments[key] then
          if DoesEntityExist(Sling.cachedAttachments[key].obj) then
            DeleteEntity(Sling.cachedAttachments[key].obj)
            NetworkUnregisterNetworkedEntity(Sling.cachedAttachments[key].obj)
            DeleteObject(Sling.cachedAttachments[key].obj)
            DetachEntity(Sling.cachedAttachments[key].placeholder, true, false)
            DeleteObject(Sling.cachedAttachments[key].placeholder)
            Sling.currentAttachedAmount = Sling.currentAttachedAmount - 1
          end
        end
        Sling.cachedWeapons[key] = nil
      end
    end
    Wait(1500);
  end
end)

function IsPlayerLoaded()
  return isPlayerLoaded;
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
  isPlayerLoaded = true;
end)
