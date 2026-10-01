-- Config.Weapons is shared, so normalize it here too: the server validates weapon names against it
NormalizeWeaponConfig()

CreateThread(function()
  Sling:InitMain()
end)
