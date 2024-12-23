Sling = {}

function Sling:InitMain()
  lib.print.info("Initializing main")
  Sling:Debug("info", "Initializing main")

  Sling:LoadServerCallbacks()

  lib.print.info("Main initialized")
  Sling:Debug("info", "Main initialized")
end

function Sling:LoadServerCallbacks()
  Sling:Debug("info", "Loading server callbacks")

  local callbacks = {
    ["force-Sling:callback:isPlayerAdmin"] = function(source, target)
      Sling:Debug("info", "Checking if player is admin for source = " .. tostring(source))
      if not target then target = source end
      return Admin:IsPlayerAdmin(target)
    end,
    ["force-sling:callback:getCachedPositions"] = function(source)
      local identifier = GetPlayerIdentifierByType(source, "license")
      local positions = json.decode(LoadResourceFile(GetCurrentResourceName(), "json/positions.json")) or {}
      Sling:Debug("info", "Returning cached positions for identifier: " .. tostring(identifier))
      return positions[identifier] or {}
    end,
    ["force-sling:callback:getCachedPresets"] = function()
      Sling:Debug("info", "Returning cached presets")
      return json.decode(LoadResourceFile(GetCurrentResourceName(), "json/presets.json")) or {}
    end,
    ["force-sling:callback:resetWeaponPositions"] = function(source, weapon)
      Sling:Debug("info",
        "Resetting weapon positions for source = " .. tostring(source) .. " and weapon = " .. tostring(weapon))
      local identifier = GetPlayerIdentifierByType(source, "license")
      local positions = json.decode(LoadResourceFile(GetCurrentResourceName(), "json/positions.json")) or {}
      positions[identifier] = positions[identifier] or {}
      positions[identifier][weapon] = nil
      SaveResourceFile(GetCurrentResourceName(), "json/positions.json", json.encode(positions), -1)
      return positions[identifier]
    end
  }

  for name, func in pairs(callbacks) do
    lib.callback.register(name, func)
  end

  Sling:Debug("info", "Server callbacks loaded")
end

---@param type string The type of the debug message (error, warn, info, verbose, debug).
---@param message string The debug message to print.
function Sling:Debug(type, message)
  if not Config.Debug then return end
  lib.print[type](message)
end
