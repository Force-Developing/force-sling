Utils = {}

function Utils:CreateAndAttachWeapon(weaponName, weaponVal, coords, playerPed)
  if Sling.currentAttachedAmount >= Config.MaxWeaponsAttached then
    Sling:Debug("warn", "Max weapons attached reached")
    return false
  end

  if not weaponVal or not weaponVal.name then
    Sling:Debug("error", "Invalid weapon data")
    return false
  end

  local weaponObject = CreateWeaponObject(weaponVal.name, 0, coords.coords.x, coords.coords.y, coords.coords.z, true, 1.0, 0)
  if not weaponObject then
    Sling:Debug("error", "Failed to create weapon object")
    return false
  end

  if NetworkGetEntityIsNetworked(weaponObject) then
    NetworkUnregisterNetworkedEntity(weaponObject)
  end
  SetEntityCollision(weaponObject, false, false)
  for _, component in pairs(weaponVal.attachments) do
    GiveWeaponComponentToWeaponObject(weaponObject, component)
  end
  lib.requestModel(weaponVal.model)
  local placeholder = CreateObjectNoOffset(weaponVal.model, coords.coords.x, coords.coords.y, coords.coords.z, true,
    true, false)
  SetEntityCollision(placeholder, false, false)
  SetEntityAlpha(placeholder, 0, false)
  AttachEntityToEntity(placeholder, playerPed, GetPedBoneIndex(playerPed, (coords.boneId or DEFAULT_BONE)),
    coords.coords.x, coords.coords.y, coords.coords.z, coords.rot.x, coords.rot.y, coords.rot.z, true, true, false,
    true, 2, true)
  AttachEntityToEntity(weaponObject, placeholder, GetEntityBoneIndexByName(placeholder, "gun_root"), 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, true, true, false, true, 2, true)
  Sling.cachedAttachments[weaponName].obj = weaponObject
  Sling.cachedAttachments[weaponName].placeholder = placeholder
  Sling.currentAttachedAmount = Sling.currentAttachedAmount + 1
  SetModelAsNoLongerNeeded(weaponVal.model)

  return true
end

function Utils:DeleteWeapon(weaponName)
  local attachment = Sling.cachedAttachments[weaponName]
  if NetworkGetEntityIsNetworked(attachment.obj) then
    NetworkUnregisterNetworkedEntity(attachment.obj)
  end
  DeleteObject(attachment.obj)
  DetachEntity(attachment.placeholder, true, false)
  DeleteObject(attachment.placeholder)
  Sling.currentAttachedAmount = Sling.currentAttachedAmount - 1
end
