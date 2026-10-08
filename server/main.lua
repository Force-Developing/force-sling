-- Config.Weapons is shared, so normalize it here too: the server validates weapon names against it
NormalizeWeaponConfig()
-- Detects the framework and inventory and replicates the decision to clients (GlobalState)
InitEnvironment()

CreateThread(function()
  Sling:InitMain()
end)
