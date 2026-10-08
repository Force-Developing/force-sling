-- Runs once force-sling knows the framework is "qbx" (Config.Framework.name, or detected by the server)
RegisterFramework("qbx", function()
  local resource = GetFrameworkResource("qbx_core")
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
    local playerData = exports[resource]:GetPlayerData()
    return playerData and playerData.items
  end

  RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    isPlayerLoaded = true
  end)
end)
