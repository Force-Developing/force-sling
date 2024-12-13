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
      DeleteEntity(attachment.obj)
    end
  end

  Sling:Debug("info", "Resource stopped: " .. resource)
end)
