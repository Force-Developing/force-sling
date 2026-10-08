local function cleanupEntities()
  local function safeDelete(entity)
    if DoesEntityExist(entity) then
      if IsEntityAttachedToAnyPed(entity) then
        DetachEntity(entity, true, true)
      end
      DeleteObject(entity)
      SetEntityAsNoLongerNeeded(entity)
      return true
    end
    return false
  end

  if Sling.object then
    safeDelete(Sling.object)
    Sling.object = nil
  end

  for weaponName, attachment in pairs(Sling.cachedAttachments) do
    if attachment then
      safeDelete(attachment.obj)
      safeDelete(attachment.placeholder)
      Sling.cachedAttachments[weaponName] = nil
    end
  end

  Sling.currentAttachedAmount = 0

  -- The text UI and the menu live in ox_lib and would stay on screen after this resource is gone
  if Sling.inPositioning then
    Sling.inPositioning = false
    lib.hideTextUI()
  end
  if lib.getOpenMenu() == "sling_select" then
    lib.hideMenu(false)
  end
end

AddEventHandler("onResourceStop", function(resource)
  if resource ~= GetCurrentResourceName() then
    return
  end

  Debug("info", "Resource stopping: " .. resource)
  cleanupEntities()
  Debug("info", "Resource stopped: " .. resource)
end)

--- A preset was saved by an admin. Rebuild the prop unless the player has their own position for it.
RegisterNetEvent("force-sling:client:presetUpdated", function(weaponName, preset)
  preset = NormalizePosition(preset)
  if type(weaponName) ~= "string" or not preset then return end
  Sling.cachedPresets[weaponName] = preset
  if not Sling.cachedPositions[weaponName] then
    Utils:DeleteWeapon(weaponName)
  end
end)

--- The server refused a position we already show (no permission, or saved again within the throttle):
--- reload what is actually saved so the sling doesn't show a position that is gone after a rejoin.
RegisterNetEvent("force-sling:client:saveRejected", function(weaponName)
  Sling:LoadPositions()
  if type(weaponName) == "string" then
    Utils:DeleteWeapon(weaponName:lower())
  end
end)
