-- Runs once force-sling knows the framework is "qbcore" (Config.Framework.name, or detected by the server)
RegisterFramework("qbcore", function()
  local resource = GetFrameworkResource("qb-core")
  -- Loaded again when qb-core restarts: the old core object points at the stopped resource
  LoadFrameworkObject(resource, function()
    return exports[resource]:GetCoreObject()
  end, function(obj)
    QBCore = obj
  end)

  local isPlayerLoaded = false

  CreateThread(function()
    while not LocalPlayer.state.isLoggedIn and not isPlayerLoaded do
      Wait(100)
    end
    isPlayerLoaded = true
  end)

  function IsPlayerLoaded()
    return isPlayerLoaded and QBCore ~= nil
  end

  --- Items stored in the player data (qb-inventory and forks). Used when no dedicated inventory export is configured.
  function GetFrameworkItems()
    if not QBCore then return nil end
    local playerData = QBCore.Functions.GetPlayerData()
    return playerData and playerData.items
  end

  RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    isPlayerLoaded = true
  end)
end)
