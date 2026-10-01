Sling = {}

function Sling:InitMain()
  Debug("info", "Initializing main")

  Sling:LoadServerCallbacks()

  Debug("info", "Main initialized")
end

function Sling:LoadServerCallbacks()
  Debug("info", "Loading server callbacks")

  local resourceName = GetCurrentResourceName()
  local callbacks = {
    -- Only ever answers for the caller; letting clients pass a target leaked other players' admin status
    ["force-sling:callback:isPlayerAdmin"] = function(source)
      return Admin:IsPlayerAdmin(source)
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
      local weaponName = GetConfiguredWeaponName(weapon)
      if not identifier or not weaponName or not Admin:HasPermission(source, Config.Command.permission) then
        return identifier and positions[identifier] or {}
      end
      positions[identifier] = positions[identifier] or {}
      positions[identifier][weaponName] = nil
      SaveResourceFile(resourceName, "json/positions.json", json.encode(positions), -1)
      return positions[identifier]
    end
  }

  for name, func in pairs(callbacks) do
    lib.callback.register(name, func)
  end

  Debug("info", "Server callbacks loaded")
end
