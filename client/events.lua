--- Event handler for when the resource stops.
AddEventHandler("onResourceStop", function(resource)
  -- Check if the stopped resource is the current resource
  if resource ~= GetCurrentResourceName() then
    return
  end

  Sling:Debug("info", "Resource stopping: " .. resource)

  -- Delete the Sling object if it exists
  if Sling.object and DoesEntityExist(Sling.object) then
    Sling:Debug("info", "Deleting Sling object")
    DeleteEntity(Sling.object)
  end

  -- Delete all cached attachments if they exist
  for _, attachment in pairs(Sling.cachedAttachments) do
    if DoesEntityExist(attachment.obj) then
      Sling:Debug("info", "Deleting cached attachment object")
      DeleteEntity(attachment.obj)
    end
  end

  Sling:Debug("info", "Resource stopped: " .. resource)
end)
