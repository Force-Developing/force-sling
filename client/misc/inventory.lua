Inventory = {}

function Inventory:GetWeaponAttachment(item)
  local components = {}

  if Config.Inventory == "qs-inventory" then
    local userInventory = exports['qs-inventory']:getUserInventory()
    for _, v in pairs(userInventory) do
      if v.name == item then
        for _, v3 in pairs(v.info.attachments) do
          table.insert(components, v3.component)
        end
      end
    end
  end

  return components
end
