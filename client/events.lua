AddEventHandler("onResourceStop", function(resource)
  if resource ~= GetCurrentResourceName() then
    return
  end

  Sling:Debug("info", "Resource stopping: " .. resource)

  if Sling.object and DoesEntityExist(Sling.object) then
    Sling:Debug("info", "Deleting Sling object")
    DeleteEntity(Sling.object)
  end

  for _, attachment in pairs(Sling.cachedAttachments) do
    if DoesEntityExist(attachment.obj) then
      Sling:Debug("info", "Deleting cached attachment object")
      NetworkUnregisterNetworkedEntity(attachment.obj)
      DeleteObject(attachment.obj)
      DetachEntity(attachment.placeholder, true, false)
      DeleteObject(attachment.placeholder)
    end
  end

  Sling:Debug("info", "Resource stopped: " .. resource)
end)

AddEventHandler('playerDropped', function()
  if Sling.object and DoesEntityExist(Sling.object) then
    Sling:Debug("info", "Deleting Sling object")
    DeleteEntity(Sling.object)
  end

  for _, attachment in pairs(Sling.cachedAttachments) do
    if DoesEntityExist(attachment.obj) then
      Sling:Debug("info", "Deleting cached attachment object")
      NetworkUnregisterNetworkedEntity(attachment.obj)
      DeleteObject(attachment.obj)
      DetachEntity(attachment.placeholder, true, false)
      DeleteObject(attachment.placeholder)
    end
  end
  Sling:Debug("info", "Player dropped")
end)
