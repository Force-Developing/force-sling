-- Personal positions are capped to a small box around the bone so nobody can park a prop
-- metres away from their ped. The shipped presets go up to 0.35, hence 0.5 rather than the
-- client's 0.2 move clamp (moving an axis that started outside that range is still allowed).
local POSITION_LIMIT = 0.5
local ROTATION_LIMIT = 360.0
local SAVE_COOLDOWN_MS = 1000

local lastSave = {}

local function SafeSavePosition(filePath, data)
  local success, error = pcall(function()
    local fileData = json.decode(LoadResourceFile(GetCurrentResourceName(), filePath)) or {}
    fileData = type(fileData) == 'table' and fileData or {}

    -- Merge one level deep so saving one weapon doesn't wipe the player's other weapons
    for k, v in pairs(data) do
      if type(v) == 'table' and type(fileData[k]) == 'table' then
        for weaponName, position in pairs(v) do
          fileData[k][weaponName] = position
        end
      else
        fileData[k] = v
      end
    end

    return SaveResourceFile(GetCurrentResourceName(), filePath, json.encode(fileData, { indent = true }), -1)
  end)

  if not success then
    Debug("error", "Failed to save position data: " .. tostring(error))
    return false
  end
  return true
end

local function toFiniteNumber(value)
  value = tonumber(value)
  if not value or value ~= value or value == math.huge or value == -math.huge then
    return nil
  end
  return value
end

--- Copies x/y/z from a vector3 or table into a plain table, or returns nil if any axis is invalid.
local function sanitizeVector(value, sanitize)
  local valueType = type(value)
  if valueType ~= "table" and valueType ~= "vector3" then return nil end

  local result = {}
  for _, axis in ipairs({ "x", "y", "z" }) do
    local number = toFiniteNumber(value[axis])
    if not number then return nil end
    result[axis] = sanitize(number)
  end
  return result
end

local function clampPosition(value)
  return math.max(-POSITION_LIMIT, math.min(POSITION_LIMIT, value))
end

local function wrapRotation(value)
  -- fmod keeps the orientation (370 == 10) while bounding the value to (-360, 360)
  return math.fmod(value, ROTATION_LIMIT)
end

local function isConfiguredBone(boneId)
  boneId = tonumber(boneId)
  if not boneId then return false end
  for _, configuredBone in pairs(Config.Bones) do
    if configuredBone == boneId then return true end
  end
  return false
end

--- Returns the lowercase Config.Weapons key, or nil when the weapon isn't configured.
function GetConfiguredWeaponName(weaponName)
  if type(weaponName) ~= "string" then return nil end
  weaponName = weaponName:lower()
  return Config.Weapons[weaponName] and weaponName or nil
end

local function reject(src, reason)
  lib.print.warn(("Rejected sling position from player %s: %s"):format(src, reason))
end

--- @param coords table The coordinates of the weapon.
--- @param rot table The rotation of the weapon.
--- @param weapon number The weapon model (unused, the server uses Config.Weapons).
--- @param weaponName string The weapon name.
--- @param boneId number The bone ID to attach the weapon to.
--- @param isPreset boolean Whether the position is a preset.
--- @return nil
RegisterNetEvent("force-sling:server:saveWeaponPosition", function(coords, rot, weapon, weaponName, boneId, isPreset)
  local src = source

  local now = GetGameTimer()
  if lastSave[src] and now - lastSave[src] < SAVE_COOLDOWN_MS then return end
  lastSave[src] = now

  isPreset = isPreset == true
  local permission = isPreset and Config.Presets.permission or Config.Command.permission
  if not Admin:HasPermission(src, permission) then
    return reject(src, ("missing permission %s for %s"):format(tostring(permission), isPreset and "presets" or "positions"))
  end

  local configuredName = GetConfiguredWeaponName(weaponName)
  if not configuredName then
    return reject(src, ("weapon %s is not in Config.Weapons"):format(tostring(weaponName)))
  end

  local position = sanitizeVector(coords, clampPosition)
  local rotation = sanitizeVector(rot, wrapRotation)
  if not position or not rotation then
    return reject(src, "invalid coords or rotation")
  end

  if not isConfiguredBone(boneId) then
    return reject(src, ("bone %s is not in Config.Bones"):format(tostring(boneId)))
  end

  local entry = { coords = position, rot = rotation, boneId = tonumber(boneId) }
  Debug("info", "Saving weapon position for weapon: " .. configuredName .. " isPreset: " .. tostring(isPreset))

  if not isPreset then
    local identifier = GetPlayerIdentifierByType(src, "license")
    if not identifier then
      return reject(src, "no license identifier")
    end

    if SafeSavePosition("json/positions.json", { [identifier] = { [configuredName] = entry } }) then
      Debug("info", "Weapon position saved for player: " .. identifier .. " weapon: " .. configuredName)
    end
  else
    if SafeSavePosition("json/presets.json", { [configuredName] = entry }) then
      Debug("info", "Weapon preset saved for weapon: " .. configuredName)
    end
  end
end)

AddEventHandler("playerDropped", function()
  lastSave[source] = nil
end)
