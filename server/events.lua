--- @param coords table The coordinates of the weapon.
--- @param rot table The rotation of the weapon.
--- @param weapon string The weapon model.
--- @param weaponName string The weapon name.
--- @param boneId number The bone ID to attach the weapon to.
--- @param isPreset boolean Whether the position is a preset.
--- @return nil
RegisterNetEvent("force-sling:server:saveWeaponPosition", function(coords, rot, weapon, weaponName, boneId, isPreset)
  Sling:Debug("info", "Saving weapon position for weapon: " .. weaponName .. " isPreset: " .. tostring(isPreset))

  if not isPreset then
    local positions = json.decode(LoadResourceFile(GetCurrentResourceName(), "json/positions.json")) or {}
    local identifier = GetPlayerIdentifierByType(source, "license")

    if not positions[identifier] then
      positions[identifier] = {}
    end

    -- Update the weapon position for the player
    positions[identifier][weaponName] = {
      coords = coords,
      rot = rot,
      boneId = boneId
    }

    SaveResourceFile(GetCurrentResourceName(), "json/positions.json", json.encode(positions, { indent = true }), -1)
    Sling:Debug("info", "Weapon position saved for player: " .. identifier .. " weapon: " .. weaponName)
  else
    local presets = json.decode(LoadResourceFile(GetCurrentResourceName(), "json/presets.json")) or {}

    -- Update the weapon preset
    presets[weaponName] = {
      coords = coords,
      rot = rot,
      boneId = boneId
    }

    SaveResourceFile(GetCurrentResourceName(), "json/presets.json", json.encode(presets, { indent = true }), -1)
    Sling:Debug("info", "Weapon preset saved for weapon: " .. weaponName)
  end
end)
