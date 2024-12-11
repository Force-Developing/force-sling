if Config.Framework.name ~= "qbcore" then
  return;
end

QBCore = exports[(Config.Framework.resource == "auto" and "qb-core" or Config.Framework.resource)]:GetCoreObject();

function GetPlayerFromId(target)
  return QBCore.Functions.GetPlayer(target);
end

function GetPlayerIdentifierFromId(target)
  return GetPlayerFromId(target).PlayerData.citizenid;
end

function GetPlayerMoney(target)
  return GetPlayerFromId(target).PlayerData.money.cash;
end

function AddMoney(target, amount)
  GetPlayerFromId(target).Functions.AddMoney("cash", amount, "Storage Unit");
end

function RemoveMoney(target, amount)
  GetPlayerFromId(target).Functions.RemoveMoney("cash", amount, "Storage Unit");
end

function AddInventoryItem(target, item, amount, metadata, slot)
  GetPlayerFromId(target).Functions.AddItem(item, amount, slot or nil, metadata);
end
