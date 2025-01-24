local function cleanupEntities()
  if Sling.object and DoesEntityExist(Sling.object) then
    DeleteEntity(Sling.object)
    Sling.object = nil
  end

  for weaponName, attachment in pairs(Sling.cachedAttachments) do
    if attachment then
      if DoesEntityExist(attachment.obj) then
        DeleteEntity(attachment.obj)
      end
      if DoesEntityExist(attachment.placeholder) then
        DeleteEntity(attachment.placeholder)
      end
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

  Sling:Debug("info", "Resource stopping: " .. resource)
  cleanupEntities()
  Sling:Debug("info", "Resource stopped: " .. resource)
end)

AddEventHandler('playerDropped', function()
  cleanupEntities()
  Sling:Debug("info", "Player dropped")
end)
