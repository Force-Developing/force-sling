if Config.Framework.name ~= "qbcore" then
  return
end

QBCore = exports[(Config.Framework.resource == "auto" and "qb-core" or Config.Framework.resource)]:GetCoreObject()

local isPlayerLoaded = false

CreateThread(function()
  while not LocalPlayer.state.isLoggedIn and not isPlayerLoaded do
    Wait(100)
  end
  isPlayerLoaded = true
end)

function IsPlayerLoaded()
  return isPlayerLoaded
end

--- Items stored in the player data (qb-inventory and forks). Used when no dedicated inventory export is configured.
function GetFrameworkItems()
  local playerData = QBCore.Functions.GetPlayerData()
  return playerData and playerData.items
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
  isPlayerLoaded = true
end)
