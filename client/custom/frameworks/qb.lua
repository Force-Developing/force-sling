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
      -- for k, v in pairs(Config.Weapons) do
      --   if item == k then
      --     Sling.cachedWeapons[item] = v
      --     Sling.cachedWeapons[item].attachments = Inventory:GetWeaponAttachment(item)
      --   end
      -- end
      Wait(1500);
    end
  end)
end)
