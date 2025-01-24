-- Better resource cleanup
local function cleanupEntities()
  local function safeDelete(entity)
    if DoesEntityExist(entity) then
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

AddEventHandler('playerDropped', function()
  cleanupEntities()
  Debug("info", "Player dropped")
end)
