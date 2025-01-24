lib.locale(Config.Locale);

InitFramework()
InitInventory()

CreateThread(function()
  while not IsPlayerLoaded() do
    Wait(100)
  end

  Sling:InitMain()
end)
