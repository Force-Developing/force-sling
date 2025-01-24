Admin = {}

--- Checks if a player is an admin.
---
--- This function determines if a player is an admin by checking their Discord roles
--- and global configuration settings.
---
--- @param target number The target player.
--- @return boolean | string The player's admin status and type.
--- - `isAdmin` (boolean): Whether the player is an admin.
--- - `adminType` (string): The type of admin ("none" or "global").
function Admin:IsPlayerAdmin(target)
  Debug("info", "Checking if player is admin for target: " .. tostring(target))
  --- @type boolean | string
  local admin = false;

  -- Check if the player is an admin via global configuration
  if Config.Admin.Global.enabled and not admin then
    if Config.Admin.Global.ace then
      local isAdceAllowed = IsPlayerAceAllowed(target, Config.Admin.Global.ace)
      if isAdceAllowed then
        admin = "global"
      end
    end

    local identifiers = GetPlayerIdentifiers(target)
    for _, identifier in ipairs(identifiers) do
      if lib.table.contains(Config.Admin.Global.players, identifier) then
        admin = "global"
        break
      end
    end
  end

  Debug("info",
    "Admin check completed for target: " ..
    tostring(target) .. " admin: " .. tostring(admin))
  return admin
end

--- Gets a player's identifier.
---
--- This function retrieves a specific type of identifier for a given player.
--- It logs the process of finding the identifier and returns the identifier if found.
---
--- @param target number The target player.
--- @param identifierType string The type of identifier to get.
--- @return string | nil The player's identifier.
function Admin:getPlayerIdentifier(target, identifierType)
  Debug("info",
    "Getting player identifier for target: " .. tostring(target) .. " identifierType: " .. identifierType)
  local identifiers = GetPlayerIdentifiers(target)
  for _, identifier in ipairs(identifiers) do
    if string.find(identifier, identifierType) then
      Debug("info", "Player identifier for target: " .. tostring(target) .. " is: " .. tostring(identifier))
      return identifier
    end
  end
  Debug("info", "Player identifier for target: " .. tostring(target) .. " not found")
  return nil
end
