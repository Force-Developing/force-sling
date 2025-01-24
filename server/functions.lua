Sling = {}

function Sling:InitMain()
  lib.print.info("Initializing main")
  Debug("info", "Initializing main")

  Sling:LoadServerCallbacks()

  lib.print.info("Main initialized")
  Debug("info", "Main initialized")
end

function Sling:LoadServerCallbacks()
  Debug("info", "Loading server callbacks")

  local resourceName = GetCurrentResourceName()
  local callbacks = {
    ["force-sling:callback:isPlayerAdmin"] = function(source, target)
      if not target then target = source end
      return Admin:IsPlayerAdmin(target)
    end,
    ["force-sling:callback:getCachedPositions"] = function(source)
      local identifier = GetPlayerIdentifierByType(source, "license")
      local positions = json.decode(LoadResourceFile(resourceName, "json/positions.json")) or {}
      Debug("info", "Returning cached positions for identifier: " .. tostring(identifier))
      return positions[identifier] or {}
    end,
    ["force-sling:callback:getCachedPresets"] = function()
      Debug("info", "Returning cached presets")
      return json.decode(LoadResourceFile(resourceName, "json/presets.json")) or {}
    end,
    ["force-sling:callback:resetWeaponPositions"] = function(source, weapon)
      Debug("info",
        "Resetting weapon positions for source = " .. tostring(source) .. " and weapon = " .. tostring(weapon))
      local identifier = GetPlayerIdentifierByType(source, "license")
      local positions = json.decode(LoadResourceFile(resourceName, "json/positions.json")) or {}
      positions[identifier] = positions[identifier] or {}
      positions[identifier][weapon] = nil
      SaveResourceFile(resourceName, "json/positions.json", json.encode(positions), -1)
      return positions[identifier]
    end
  }

  for name, func in pairs(callbacks) do
    lib.callback.register(name, func)
  end

  Debug("info", "Server callbacks loaded")
end
