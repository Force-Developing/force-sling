lib.locale(Config.Locale);

Sling:InitFramework()
Sling:LoadInventory()

CreateThread(function()
  while not IsPlayerLoaded() do
    Wait(100)
  end

  Sling:InitMain()
end)
