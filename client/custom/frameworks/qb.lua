if Config.Framework.name ~= "qbcore" then
  return
end

QBCore = exports[(Config.Framework.resource == "auto" and "qb-core" or Config.Framework.resource)]:GetCoreObject()

local isPlayerLoaded = false

CreateThread(function()
  while not LocalPlayer.state.isLoggedIn and not isPlayerLoaded do
    Wait(100)
  end
  isPlayerLoaded = true

  local lower = string.lower

  while true do
    local xPlayer = QBCore.Functions.GetPlayerData()
    if not xPlayer or not xPlayer.items then
      Wait(1000)
    else
      local cachedItems = {}
      for _, v in pairs(xPlayer.items) do
        local itemName = lower(v.name)
        if Config.Weapons[itemName] then
          cachedItems[itemName] = true
          Sling.cachedWeapons[itemName] = Config.Weapons[itemName]
          Sling.cachedWeapons[itemName].attachments = Inventory:GetWeaponAttachment(itemName)
        end
      end

      for key, val in pairs(Config.Weapons) do
        local lowerKey = lower(key)
        if not cachedItems[lowerKey] then
          if Sling.cachedAttachments[lowerKey] then
            local attachment = Sling.cachedAttachments[lowerKey]
            if DoesEntityExist(attachment.obj) or DoesEntityExist(attachment.placeholder) then
              DeleteEntity(attachment.obj)
              NetworkUnregisterNetworkedEntity(attachment.obj)
              DeleteObject(attachment.obj)
              DetachEntity(attachment.placeholder, true, false)
              DeleteObject(attachment.placeholder)
              Sling.currentAttachedAmount = Sling.currentAttachedAmount - 1
            end
          end
          Sling.cachedWeapons[lowerKey] = nil
        end
      end
      Wait(1500)
    end
  end
end)

function IsPlayerLoaded()
  return isPlayerLoaded
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
  isPlayerLoaded = true
end)
