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
  collectgarbage("collect")
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
  if type(weaponName) ~= "string" or type(preset) ~= "table" or type(preset.coords) ~= "table" then return end
  Sling.cachedPresets[weaponName] = preset
  if not Sling.cachedPositions[weaponName] then
    Utils:DeleteWeapon(weaponName)
  end
end)
