InitLocale()
NormalizeWeaponConfig()
-- Framework and inventory come from the server (GlobalState); the framework files run once it has decided
InitEnvironment()

CreateThread(function()
  while not IsFrameworkReady() or not IsPlayerLoaded() do
    Wait(100)
  end

  Sling:InitMain()
end)
