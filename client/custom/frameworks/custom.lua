if Config.Framework.name ~= "custom" then
  return;
end

Framework = {};
Framework.PlayerLoadedEvent = "esx:playerLoaded"

function Notify(msg, type)
  lib.notify({
    title = Locale["Sling"],
    description = msg,
    type = type
  })
end

function IsPlayerLoaded()
  return true;
end
