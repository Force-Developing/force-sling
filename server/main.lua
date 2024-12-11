-- Initialize the framework
Sling:InitFramework()

-- Initialize the inventory
Sling:LoadInventory()

-- Create a new thread to initialize the main functionality
CreateThread(function()
  Sling:InitMain()
end)

--- Loads server callbacks
function Sling:LoadServerCallbacks()
  Sling:Debug("info", "Loading server callbacks")

  -- Register callback to check if a player is an admin
  lib.callback.register("force-Sling:callback:isPlayerAdmin", function(source, target)
    Sling:Debug("info", "Checking if player is admin for source = " .. tostring(source))
    if not target then target = source end
    return Admin:IsPlayerAdmin(target)
  end)

  lib.callback.register("force-sling:callback:getCachedPositions", function(source)
    local identifier = GetPlayerIdentifierByType(source, "license")
    local positions = json.decode(LoadResourceFile(GetCurrentResourceName(), "json/positions.json")) or {}
    return positions[identifier] or {}
  end)

  Sling:Debug("info", "Server callbacks loaded")
end
