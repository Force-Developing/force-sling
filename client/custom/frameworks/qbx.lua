if Config.Framework.name ~= "qbx" then
  return
end

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

--- Items stored in the player data. Used when no dedicated inventory export is configured.
function GetFrameworkItems()
  local playerData = exports.qbx_core:GetPlayerData()
  return playerData and playerData.items
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
  isPlayerLoaded = true
end)
