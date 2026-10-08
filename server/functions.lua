Sling = {}

local resourceName = GetCurrentResourceName()

POSITIONS_FILE = "json/positions.json"
-- Shipped defaults, overwritten when the resource is updated
PRESETS_FILE = "json/presets.json"
-- Presets saved in-game with the preset command; not part of the release, so updates keep them
CUSTOM_PRESETS_FILE = "json/presets_custom.json"

--- Reads a JSON object from the resource folder.
--- @return table data Empty table when the file is missing, empty or broken
--- @return boolean valid False when the file has content that isn't a JSON object (don't overwrite it)
function ReadJsonFile(path)
  local raw = LoadResourceFile(resourceName, path)
  if not raw or raw:match("^%s*$") then return {}, true end

  local ok, data = pcall(json.decode, raw)
  if not ok or type(data) ~= "table" then
    lib.print.error(("%s is not valid JSON, fix or delete it. Saving to it is disabled until then."):format(path))
    return {}, false
  end
  return data, true
end

function WriteJsonFile(path, data)
  return SaveResourceFile(resourceName, path, json.encode(data, { indent = true }), -1)
end

--- Shipped presets with the in-game saved ones layered on top, per weapon.
--- Invalid entries (hand edits, json null) are left out.
function GetPresets()
  local presets = NormalizePositions(ReadJsonFile(PRESETS_FILE))
  for weaponName, preset in pairs(NormalizePositions(ReadJsonFile(CUSTOM_PRESETS_FILE))) do
    presets[weaponName] = preset
  end
  return presets
end

function Sling:InitMain()
  Debug("info", "Initializing main")

  -- positions.json isn't shipped (an update would wipe player data), so create it on first start
  if not LoadResourceFile(resourceName, POSITIONS_FILE) then
    WriteJsonFile(POSITIONS_FILE, {})
  end

  Sling:LoadServerCallbacks()

  Debug("info", "Main initialized")
end

function Sling:LoadServerCallbacks()
  Debug("info", "Loading server callbacks")

  local callbacks = {
    -- Only ever answers for the caller; letting clients pass a target leaked other players' admin status
    ["force-sling:callback:isPlayerAdmin"] = function(source)
      return Admin:IsPlayerAdmin(source)
    end,
    ["force-sling:callback:getCachedPositions"] = function(source)
      local identifier = GetPlayerIdentifierByType(source, "license")
      Debug("info", "Returning cached positions for identifier: " .. tostring(identifier))
      return identifier and NormalizePositions(ReadJsonFile(POSITIONS_FILE)[identifier]) or {}
    end,
    ["force-sling:callback:getCachedPresets"] = function()
      Debug("info", "Returning cached presets")
      return GetPresets()
    end,
    ["force-sling:callback:resetWeaponPositions"] = function(source, weapon)
      Debug("info",
        "Resetting weapon positions for source = " .. tostring(source) .. " and weapon = " .. tostring(weapon))
      local identifier = GetPlayerIdentifierByType(source, "license")
      local positions, valid = ReadJsonFile(POSITIONS_FILE)
      local weaponName = GetConfiguredWeaponName(weapon)
      if not identifier or not weaponName or not valid or not Admin:HasPermission(source, Config.Command.permission) then
        return identifier and NormalizePositions(positions[identifier]) or {}
      end
      -- json null decodes to a (truthy) function, so check the type
      if type(positions[identifier]) ~= "table" then positions[identifier] = {} end
      positions[identifier][weaponName] = nil
      WriteJsonFile(POSITIONS_FILE, positions)
      return NormalizePositions(positions[identifier])
    end
  }

  for name, func in pairs(callbacks) do
    lib.callback.register(name, func)
  end

  Debug("info", "Server callbacks loaded")
end
