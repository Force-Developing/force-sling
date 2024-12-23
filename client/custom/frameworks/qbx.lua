if Config.Framework.name ~= "qbx" then
  return
end

local isPlayerLoaded = false

CreateThread(function()
  while not LocalPlayer.state.isLoggedIn and not isPlayerLoaded do
    Wait(100)
  end
  isPlayerLoaded = true

  local cachedItems = {}
  local lower = string.lower
  local ConfigWeapons = Config.Weapons
  local SlingCachedWeapons = Sling.cachedWeapons
  local SlingCachedAttachments = Sling.cachedAttachments

  while true do
    local xPlayer = exports.qbx_core:GetPlayerData()
    if not xPlayer or not xPlayer.items then
      Wait(1000)
    else
      for _, v in pairs(xPlayer.items) do
        local itemName = lower(v.name)
        if ConfigWeapons[itemName] then
          cachedItems[itemName] = true
          SlingCachedWeapons[itemName] = ConfigWeapons[itemName]
          SlingCachedWeapons[itemName].attachments = Inventory:GetWeaponAttachment(itemName)
        end
      end

      for key, _ in pairs(ConfigWeapons) do
        local lowerKey = lower(key)
        if not cachedItems[lowerKey] then
          if SlingCachedAttachments[lowerKey] then
            local attachment = SlingCachedAttachments[lowerKey]
            if DoesEntityExist(attachment.obj) or DoesEntityExist(attachment.placeholder) then
              DeleteEntity(attachment.obj)
              NetworkUnregisterNetworkedEntity(attachment.obj)
              DeleteObject(attachment.obj)
              DetachEntity(attachment.placeholder, true, false)
              DeleteObject(attachment.placeholder)
              Sling.currentAttachedAmount = Sling.currentAttachedAmount - 1
            end
          end
          SlingCachedWeapons[lowerKey] = nil
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
