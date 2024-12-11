Admin = {}

--- Checks if a player is an admin.
--- @param target number The target player.
--- @return table A table containing isAdmin and adminType.
function Admin:IsPlayerAdmin(target)
  Sling:Debug("info", "Checking if player is admin for target: " .. tostring(target))
  local isAdmin = false
  local adminType = "none"

  -- Check if the player is an admin via Discord roles
  if Discord.enabled then
    local discordId = Admin:getPlayerIdentifier(target, "discord"):sub(9)
    if discordId then
      local playerRoles = Admin:getPlayerRoles(discordId)
      if playerRoles then
        for _, role in ipairs(playerRoles) do
          if lib.table.contains(Discord.roles, role) then
            isAdmin = true
            adminType = "global"
            break
          end
        end
      end
    end
  end

  -- Check if the player is an admin via global configuration
  if Config.Admin.Global.enabled and not isAdmin then
    local identifiers = GetPlayerIdentifiers(target)
    for _, identifier in ipairs(identifiers) do
      if lib.table.contains(Config.Admin.Global.players, identifier) then
        isAdmin = true
        adminType = "global"
        break
      end
    end
  end

  Sling:Debug("info",
    "Admin check completed for target: " ..
    tostring(target) .. " isAdmin: " .. tostring(isAdmin) .. " adminType: " .. tostring(adminType))
  return { isAdmin = isAdmin, adminType = adminType }
end

--- Gets a player's identifier.
--- @param target number The target player.
--- @param identifierType string The type of identifier to get.
--- @return string | nil The player's identifier.
function Admin:getPlayerIdentifier(target, identifierType)
  Sling:Debug("info",
    "Getting player identifier for target: " .. tostring(target) .. " identifierType: " .. identifierType)
  local identifiers = GetPlayerIdentifiers(target)
  for _, identifier in ipairs(identifiers) do
    if string.find(identifier, identifierType) then
      Sling:Debug("info", "Player identifier for target: " .. tostring(target) .. " is: " .. tostring(identifier))
      return identifier
    end
  end
  Sling:Debug("info", "Player identifier for target: " .. tostring(target) .. " not found")
  return nil
end

--- Gets a player's roles from Discord.
--- @param discordId string The player's Discord ID.
--- @return table The player's roles.
function Admin:getPlayerRoles(discordId)
  Sling:Debug("info", "Getting player roles for discordId: " .. tostring(discordId))
  local playerRoles = {}
  local checked = false

  if discordId then
    PerformHttpRequest("https://discord.com/api/v8/guilds/" .. Discord.guild .. "/members/" .. discordId,
      function(code, data, headers)
        if tonumber(code) == 200 then
          data = json.decode(data)
          for _, role in ipairs(data.roles) do
            table.insert(playerRoles, tonumber(role))
          end
        end
        checked = true
      end, "GET", "", {
        ['Content-Type'] = 'application/json',
        ["Authorization"] = "Bot " .. Discord.token
      })
  else
    checked = true
  end

  repeat Citizen.Wait(50) until checked

  Sling:Debug("info", "Player roles for discordId: " .. tostring(discordId) .. " are: " .. json.encode(playerRoles))
  return playerRoles
end
