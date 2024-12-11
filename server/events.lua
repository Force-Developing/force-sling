RegisterNetEvent("force-sling:server:saveWeaponPosition", function(coords, rot, weapon, weaponName)
  local positions = json.decode(LoadResourceFile(GetCurrentResourceName(), "json/positions.json")) or {}
  local identifier = GetPlayerIdentifierByType(source, "license")

  if not positions[identifier] then
    positions[identifier] = {}
  end

  positions[identifier][weaponName] = {
    coords = coords,
    rot = rot,
  }

  SaveResourceFile(GetCurrentResourceName(), "json/positions.json", json.encode(positions, { indent = true }), -1)
end)
