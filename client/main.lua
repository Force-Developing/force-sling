InitLocale()

InitFramework()
InitInventory()
NormalizeWeaponConfig()

CreateThread(function()
  while not IsPlayerLoaded or not IsPlayerLoaded() do
    Wait(100)
  end

  Sling:InitMain()
end)
