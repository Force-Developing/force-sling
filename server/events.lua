local function SafeSavePosition(filePath, data)
  local success, error = pcall(function()
    local fileData = json.decode(LoadResourceFile(GetCurrentResourceName(), filePath)) or {}
    fileData = type(fileData) == 'table' and fileData or {}

    for k, v in pairs(data) do
      fileData[k] = v
    end

    return SaveResourceFile(GetCurrentResourceName(), filePath, json.encode(fileData, { indent = true }), -1)
  end)

  if not success then
    Debug("error", "Failed to save position data: " .. tostring(error))
    return false
  end
  return true
end

--- @param coords table The coordinates of the weapon.
--- @param rot table The rotation of the weapon.
--- @param weapon string The weapon model.
--- @param weaponName string The weapon name.
--- @param boneId number The bone ID to attach the weapon to.
--- @param isPreset boolean Whether the position is a preset.
--- @return nil
RegisterNetEvent("force-sling:server:saveWeaponPosition", function(coords, rot, weapon, weaponName, boneId, isPreset)
  Debug("info", "Saving weapon position for weapon: " .. weaponName .. " isPreset: " .. tostring(isPreset))

  if not isPreset then
    local positions = {
      [GetPlayerIdentifierByType(source, "license")] = {
        [weaponName] = {
          coords = coords,
          rot = rot,
          boneId = boneId
        }
      }
    }

    if SafeSavePosition("json/positions.json", positions) then
      Debug("info",
        "Weapon position saved for player: " .. GetPlayerIdentifierByType(source, "license") .. " weapon: " .. weaponName)
    end
  else
    local presets = {
      [weaponName] = {
        coords = coords,
        rot = rot,
        boneId = boneId
      }
    }

    if SafeSavePosition("json/presets.json", presets) then
      Debug("info", "Weapon preset saved for weapon: " .. weaponName)
    end
  end
end)
