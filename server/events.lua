RegisterNetEvent("force-sling:server:saveWeaponPosition", function(coords, rot, weapon, weaponName, boneId, isPreset)
  if not isPreset then
    local positions = json.decode(LoadResourceFile(GetCurrentResourceName(), "json/positions.json")) or {}
    local identifier = GetPlayerIdentifierByType(source, "license")

    if not positions[identifier] then
      positions[identifier] = {}
    end

    positions[identifier][weaponName] = {
      coords = coords,
      rot = rot,
      boneId = boneId
    }

    SaveResourceFile(GetCurrentResourceName(), "json/positions.json", json.encode(positions, { indent = true }), -1)
  else
    local presets = json.decode(LoadResourceFile(GetCurrentResourceName(), "json/presets.json")) or {}

    presets[weaponName] = {
      coords = coords,
      rot = rot,
      boneId = boneId
    }

    SaveResourceFile(GetCurrentResourceName(), "json/presets.json", json.encode(presets, { indent = true }), -1)
  end
end)
