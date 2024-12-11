if Config.Framework.name ~= "esx" then
  return;
end

ESX = exports[(Config.Framework.resource == "auto" and "es_extended" or Config.Framework.resource)]:getSharedObject();

Framework = {};

function IsPlayerLoaded()
  return ESX.IsPlayerLoaded();
end

function Notify(msg, type)
  lib.notify({
    title = Locale["Sling"],
    description = msg,
    type = type
  })
end
