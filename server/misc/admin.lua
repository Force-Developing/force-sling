Admin = {}

--- Checks if a player is an admin.
--- @param target number The target player.
--- @return table A table containing isAdmin and adminType.
function Admin:IsPlayerAdmin(target)
  Sling:Debug("info", "Checking if player is admin for target: " .. tostring(target))
  local isAdmin
  local adminType

  -- Check if the player is an admin via Discord roles
  if Discord.enabled then
    local discordId = Admin:getPlayerIdentifier(target, "discord"):sub(9)
    if discordId then
      local playerRoles = Admin:getPlayerRoles(discordId)
      if playerRoles then
        for i = 1, #Discord.roles do
          for a = 1, #playerRoles do
            if playerRoles[a] == Discord.roles[i] then
              isAdmin = true
              adminType = "global"
              break
            end
          end
        end
      end
    end
  end

  -- Check if the player is an admin via global configuration
  if Config.Admin.Global.enabled then
    for i = 1, #Config.Admin.Global.players do
      local identifiers = GetPlayerIdentifiers(target)
      for _, v in pairs(identifiers) do
        if v == Config.Admin.Global.players[i] then
          isAdmin = true
          adminType = "global"
          break
        end
      end
    end
  end

  -- Wait for a maximum of 10 iterations to determine admin status
  local elapsedRepeats = 0
  repeat
    Wait(10)
    elapsedRepeats = elapsedRepeats + 1

    if elapsedRepeats >= 10 then
      if not Config.Admin.Global.enabled or not Discord.enabled then
        isAdmin = false
        adminType = "none"
      end
      break
    end
  until isAdmin ~= nil and adminType ~= nil

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
  local discordId

  for i = 1, #identifiers do
    if string.find(identifiers[i], identifierType) then
      discordId = identifiers[i]
      break
    end
    if next(identifiers) == nil then
      discordId = nil
    end
  end

  Sling:Debug("info", "Player identifier for target: " .. tostring(target) .. " is: " .. tostring(discordId))
  return discordId
end

--- Gets a player's roles from Discord.
--- @param discordId string The player's Discord ID.
--- @return table The player's roles.
function Admin:getPlayerRoles(discordId)
  Sling:Debug("info", "Getting player roles for discordId: " .. tostring(discordId))
  local playerRoles = {}
  local checked = false

  if discordId ~= nil then
    PerformHttpRequest("https://discord.com/api/v8/guilds/" .. Discord.guild .. "/members/" .. discordId,
      function(code, data, headers)
        if tonumber(code) == 200 then
          data = json.decode(data)
          for i = 1, #data.roles do
            table.insert(playerRoles, tonumber(data.roles[i]))
          end
          checked = true
        else
          checked = true
        end
      end, "GET", "", {
        ['Content-Type'] = 'application/json',
        ["Authorization"] = "Bot " .. Discord.token
      })
  else
    checked = true
  end

  repeat Citizen.Wait(50) until checked == true

  Sling:Debug("info",
    "Player roles for discordId: " .. tostring(discordId) .. " are: " .. json.encode(playerRoles))
  return playerRoles
end
