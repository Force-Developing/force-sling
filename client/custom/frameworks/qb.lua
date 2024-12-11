if Config.Framework.name ~= "qbcore" then
  return;
end

QBCore = exports[(Config.Framework.resource == "auto" and "qb-core" or Config.Framework.resource)]:GetCoreObject();

local isPlayerLoaded = false;

function IsPlayerLoaded()
  return isPlayerLoaded;
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
  isPlayerLoaded = true;
  -- Extremely unomptimized since qbcore's inventory system dosen't have a way to check when a new item is added to my knowledge
  CreateThread(function()
    while true do
      local xPlayer = QBCore.Functions.GetPlayerData()
      if not xPlayer or not xPlayer.items then
        Wait(1000);
      end
      for _, v in pairs(xPlayer.items) do
        for key, val in pairs(Config.Weapons) do
          if v.name == key then
            Sling.cachedWeapons[key] = val
            Sling.cachedWeapons[key].attachments = Inventory:GetWeaponAttachment(key)
            break
          end
        end
      end
      Wait(1500);
    end
  end)
end)
