if Config.Framework.name ~= "qbcore" then
  return;
end

QBCore = exports[(Config.Framework.resource == "auto" and "qb-core" or Config.Framework.resource)]:GetCoreObject();

function IsPlayerLoaded()
  return true;
end

function GetPlayerIdentifier()
  return QBCore.Functions.GetPlayerData().citizenid;
end

function Notify(msg, type)
  lib.notify({
    title = Locale["Sling"],
    description = msg,
    type = type
  })
end

function HasStorageKey(name)
  local inventory = QBCore.Functions.GetPlayerData().items;
  local hasKey = false;
  for i = 1, #inventory, 1 do
    if inventory[i].name == Config.Key and inventory[i].info and inventory[i].info.text == name then
      hasKey = true
      break;
    end
  end
  return hasKey;
end
