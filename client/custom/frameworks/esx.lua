if Config.Framework.name ~= "esx" then
  return;
end

ESX = exports[(Config.Framework.resource == "auto" and "es_extended" or Config.Framework.resource)]:getSharedObject();

Framework = {};

function IsPlayerLoaded()
  return ESX.IsPlayerLoaded();
end

--- Default ESX keeps weapons in the loadout instead of the inventory. The client copy of
--- PlayerData.loadout isn't updated when weapons are added or removed after login, so read the ped
--- instead: ESX gives every loadout weapon to the ped. Only used with Config.Inventory "none".
--- @return table|nil Items with .name (and .info.attachments) for every configured weapon the ped has
function GetFrameworkItems()
  if Config.Inventory ~= "none" then return nil end

  local ped = cache.ped
  local items = {}
  for name, weapon in pairs(Config.Weapons) do
    if HasPedGotWeapon(ped, weapon.name, false) then
      local attachments = {}
      if Config.UseWeaponAttachments and ESX.GetWeapon then
        local ok, _, esxWeapon = pcall(ESX.GetWeapon, name)
        for _, component in ipairs(ok and type(esxWeapon) == "table" and esxWeapon.components or {}) do
          if component.hash and HasPedGotWeaponComponent(ped, weapon.name, component.hash) then
            attachments[#attachments + 1] = { component = component.hash }
          end
        end
      end
      items[#items + 1] = { name = name, info = { attachments = attachments } }
    end
  end
  return items
end
