Sling = {}

--- Initializes the main functionality of Sling.
function Sling:InitMain()
  lib.print.info("Initializing main")
  Sling:Debug("info", "Initializing main")

  -- Load server callbacks
  Sling:LoadServerCallbacks()

  lib.print.info("Main initialized")
  Sling:Debug("info", "Main initialized")
end

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

  lib.callback.register("force-sling:callback:getCachedPresets", function()
    return json.decode(LoadResourceFile(GetCurrentResourceName(), "json/presets.json")) or {}
  end)

  Sling:Debug("info", "Server callbacks loaded")
end

--- Debug function to print messages based on the type.
---@param type string The type of the debug message (error, warn, info, verbose, debug).
---@param message string The debug message to print.
function Sling:Debug(type, message)
  if not Config.Debug then return end;
  lib.print[type](message);
end
