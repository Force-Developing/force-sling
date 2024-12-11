if Config.Framework.name ~= "esx" then
  return;
end

ESX = exports[(Config.Framework.resource == "auto" and "es_extended" or Config.Framework.resource)]:getSharedObject();

function GetPlayerFromId(target)
  return ESX.GetPlayerFromId(target);
end

function GetPlayerIdentifierFromId(target)
  return GetPlayerFromId(target).socialnumber;
end

function GetPlayerMoney(target)
  return GetPlayerFromId(target).getMoney();
end

function AddMoney(target, amount)
  GetPlayerFromId(target).addMoney(amount);
end

function RemoveMoney(target, amount)
  GetPlayerFromId(target).removeMoney(amount);
end

function AddInventoryItem(target, item, amount, metadata, slot)
  GetPlayerFromId(target).addInventoryItem(item, amount, metadata, slot);
end
