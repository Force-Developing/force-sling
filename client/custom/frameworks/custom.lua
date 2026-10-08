-- Runs once force-sling knows the framework is "custom": Config.Framework.name = "custom", or "auto" when none of
-- es_extended, qbx_core and qb-core is installed. Keep your code inside this function.
RegisterFramework("custom", function()
  Framework = {}

  --- Called every 100 ms until it returns true; the sling starts after that.
  --- TODO: replace with your framework's "character loaded" check. The default works for frameworks
  --- that set LocalPlayer.state.isLoggedIn and otherwise starts right away.
  function IsPlayerLoaded()
    return LocalPlayer.state.isLoggedIn ~= false
  end

  --- Optional. Return the items in the player's data (a list of tables with a .name field, e.g.
  --- { { name = "weapon_pistol" } }) when Config.Inventory is "none". Return nil to manage
  --- Sling.cachedWeapons yourself through events, for example:
  ---
  ---   RegisterNetEvent("myframework:weaponAdded", function(name)
  ---     name = name:lower()
  ---     if Config.Weapons[name] then Sling.cachedWeapons[name] = Config.Weapons[name] end
  ---   end)
  ---   RegisterNetEvent("myframework:weaponRemoved", function(name)
  ---     Sling.cachedWeapons[name:lower()] = nil -- the prop is removed on the next tick
  ---   end)
  function GetFrameworkItems()
    return nil
  end
end)
