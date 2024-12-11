AddEventHandler("onResourceStop", function(resource)
  if resource ~= GetCurrentResourceName() then
    return;
  end

  if Sling.object and DoesEntityExist(Sling.object) then
    DeleteEntity(Sling.object)
  end

  for _, v in pairs(Sling.cachedAttachments) do
    if DoesEntityExist(v.obj) then
      DeleteEntity(v.obj)
    end
  end
end)
