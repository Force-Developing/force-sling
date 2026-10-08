local POSITION_CLAMP = 0.2
local DEFAULT_SPEED = 0.001
local FAST_SPEED = 0.01
DEFAULT_BONE = 24816

Sling = {
  isPreset = false,

  cachedPositions = {},
  cachedPresets = {},
  cachedWeapons = {},
  cachedAttachments = {},
  currentAttachedAmount = 0,

  inPositioning = false,
  data = {
    object = nil,
  }
}

function Sling:InitMain()
  Debug("info", "Initializing main thread")

  Sling:InitSling()
  Sling:InitCommands()

  Debug("info", "Main thread initialized")
end

local menuBones, menuWeapons = {}, {}
local selectData = {}

local function sortedKeys(tbl)
  local keys = {}
  for key in pairs(tbl) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function indexOf(list, value)
  for i = 1, #list do
    if list[i] == value then return i end
  end
  return nil
end

local function selectWeapon(index)
  local weaponName = menuWeapons[index]
  selectData.weaponIndex = index
  selectData.weaponName = weaponName
  selectData.weapon = weaponName and Config.Weapons[weaponName].model
end

local function selectBone(index)
  selectData.boneIndex = index
  selectData.boneId = menuBones[index] and Config.Bones[menuBones[index]] or DEFAULT_BONE
end

--- Loads the player's saved positions and the presets from the server. Entries are validated, so a hand-edited
--- or broken JSON file can't stop the weapon thread.
function Sling:LoadPositions()
  local ok, positions = pcall(lib.callback.await, "force-sling:callback:getCachedPositions", false)
  if ok then Sling.cachedPositions = NormalizePositions(positions) end
  local okPresets, presets = pcall(lib.callback.await, "force-sling:callback:getCachedPresets", false)
  if okPresets then Sling.cachedPresets = NormalizePositions(presets) end
  if not ok or not okPresets then
    lib.print.error("Loading sling positions failed: " .. tostring(not ok and positions or presets))
  end
end

function Sling:InitSling()
  Sling:LoadPositions()
  Sling:WeaponThread()

  -- Sorted so the menu order is stable (pairs order is random)
  menuBones = sortedKeys(Config.Bones)
  menuWeapons = sortedKeys(Config.Weapons)
  selectBone(indexOf(menuBones, "Back") or 1)
  selectWeapon(1)

  lib.registerMenu({
    id = 'sling_select',
    title = locale("slingConfig"),
    position = 'top-right',
    onSideScroll = function(selected, scrollIndex, args)
      if selected == 1 then
        selectBone(scrollIndex)
      elseif selected == 2 then
        selectWeapon(scrollIndex)
      end
    end,
    onSelected = function(selected, secondary, args)
    end,
    onClose = function(keyPressed)
      Sling.inPositioning = false
    end,
    options = {
      { label = 'Bone',   values = menuBones,   args = menuBones,   defaultIndex = selectData.boneIndex },
      { label = 'Weapon', values = menuWeapons, args = menuWeapons, defaultIndex = selectData.weaponIndex },
      { label = 'Continue' },
    }
  }, function(selected, scrollIndex, args)
    if not selectData.weaponName then return end
    Debug("info", "Selected weapon: " .. selectData.weaponName)
    Debug("info", "Selected bone: " .. selectData.boneId)
    Sling:StartPositioning(selectData)
  end)
end

local DEFAULT_POSITION = {
  coords = { x = 0.0, y = -0.15, z = 0.0 },
  rot = { x = 0.0, y = 0.0, z = 0.0 },
  boneId = DEFAULT_BONE
}

--- Rebuilds cachedWeapons from the live inventory. Reading the inventory every tick (instead of
--- relying on add/remove events) means weapons show up once the inventory has loaded after join,
--- and props disappear as soon as the weapon leaves the inventory (drop, trunk, stash, sold).
--- Inventories without a readable item list (ESX default) keep using the framework events.
function Sling:SyncWeapons()
  local inventory = Inventory:GetUserInventory()
  if not inventory then return end
  Sling.cachedWeapons = Inventory:GetWeapons(inventory)
end

local lastTickError

function Sling:WeaponTick()
  Sling:SyncWeapons()

  -- Not cache.ped: it still holds the old, deleted ped for up to 100 ms after a model change
  local playerPed = PlayerPedId()
  local selectedWeapon = GetSelectedPedWeapon(playerPed)

  -- Remove props for weapons that are in hand, no longer owned, or attached to an old ped (model change)
  for weaponName, attachment in pairs(Sling.cachedAttachments) do
    local weaponVal = Sling.cachedWeapons[weaponName]
    if not weaponVal or selectedWeapon == weaponVal.name
        or not DoesEntityExist(attachment.obj)
        or not IsEntityAttachedToEntity(attachment.placeholder, playerPed) then
      Utils:DeleteWeapon(weaponName)
    end
  end

  for weaponName, weaponVal in pairs(Sling.cachedWeapons) do
    if selectedWeapon ~= weaponVal.name and not Sling.cachedAttachments[weaponName] then
      local coords = Sling.cachedPositions[weaponName] or Sling.cachedPresets[weaponName] or DEFAULT_POSITION
      Utils:CreateAndAttachWeapon(weaponName, weaponVal, coords, playerPed)
    end
  end
end

function Sling:WeaponThread()
  CreateThread(function()
    while true do
      while Sling.inPositioning do
        Wait(1000)
      end

      -- One bad weapon or inventory entry must not end the thread (no more props until a restart)
      local ok, err = pcall(Sling.WeaponTick, Sling)
      if not ok and err ~= lastTickError then
        lastTickError = err
        lib.print.error("Weapon sync failed: " .. tostring(err))
      end

      Wait(1000)
    end
  end)
end

function Sling:OnPositioningDone(coords, selectData)
  lib.hideTextUI()
  Sling.inPositioning = false
  local weapon = selectData.weapon
  coords.position = vec3(coords.position.x, coords.position.y, coords.position.z)
  local distanceFromMiddle = #(coords.position - vec3(0.0, 0.0, 0.0))
  local distanceFromMiddle2 = #(coords.position - vec3(0.0, 0.0, -0.2))
  local distanceFromMiddle3 = #(coords.position - vec3(0.0, 0.0, 0.2))
  if distanceFromMiddle < 0.14 or distanceFromMiddle2 < 0.14 or distanceFromMiddle3 < 0.14 then
    coords.position = vec3(coords.position.x, 0.17, coords.position.z)
  end
  TriggerServerEvent("force-sling:server:saveWeaponPosition", coords.position, coords.rotation, weapon,
    selectData.weaponName, selectData.boneId, Sling.isPreset)
  -- Presets come back to every client (us included) through force-sling:client:presetUpdated once the server
  -- accepted them. A personal position is used right away; force-sling:client:saveRejected reloads it if the
  -- server refused it (no permission, throttled).
  if not Sling.isPreset then
    Sling.cachedPositions[selectData.weaponName] = NormalizePosition({
      coords = coords.position,
      rot = coords.rotation,
      boneId = selectData.boneId
    })
  end
  -- Recreated by WeaponThread with the new position
  Utils:DeleteWeapon(selectData.weaponName)
  DeleteObject(Sling.object)
  SetModelAsNoLongerNeeded(selectData.weapon)
end

local function DisableControls()
  local controls = {
    25, 44, 45, 51, 140, 141, 143,
    263, 264, 24, 96, 97, 47, 74, 177
  }
  for i = 1, #controls do
    DisableControlAction(0, controls[i], true)
  end
end

function Sling:StartPositioning(data)
  if Sling.inPositioning then return end
  if type(data) ~= "table" or type(data.weaponName) ~= "string" then
    lib.print.warn("StartPositioning needs a table with weaponName")
    return
  end

  -- Copy so the caller's table isn't changed; model and bone are optional for exports
  local weaponName = data.weaponName:lower()
  local configured = Config.Weapons[weaponName]
  local selectData = {
    weaponName = weaponName,
    weapon = data.weapon or (configured and configured.model),
    boneId = data.boneId or DEFAULT_BONE,
  }

  if not selectData.weapon or not IsModelInCdimage(selectData.weapon) then
    lib.print.warn(("Can't position %s: model not found. Check Config.Weapons."):format(tostring(selectData.weaponName)))
    return
  end
  local coords = {
    position = vec3(0.0, 0.0, 0.0),
    rotation = vec3(0.0, 0.0, 0.0)
  }

  Utils:DeleteWeapon(selectData.weaponName)
  if Sling.cachedPositions[selectData.weaponName] and selectData.boneId == Sling.cachedPositions[selectData.weaponName].boneId then
    coords.position = Sling.cachedPositions[selectData.weaponName].coords
    coords.rotation = Sling.cachedPositions[selectData.weaponName].rot
  elseif Sling.cachedPresets[selectData.weaponName] and selectData.boneId == Sling.cachedPresets[selectData.weaponName].boneId then
    coords.position = Sling.cachedPresets[selectData.weaponName].coords
    coords.rotation = Sling.cachedPresets[selectData.weaponName].rot
  end

  Sling.inPositioning = true
  CreateThread(function()
    local speed = DEFAULT_SPEED
    local function updatePosition(axis, delta)
      local x, y, z = coords.position.x, coords.position.y, coords.position.z
      if axis == 'x' then
        x = lib.math.clamp(x + delta, -POSITION_CLAMP, POSITION_CLAMP)
      elseif axis == 'y' then
        y = lib.math.clamp(y + delta, -POSITION_CLAMP, POSITION_CLAMP)
      elseif axis == 'z' then
        z = lib.math.clamp(z + delta, -POSITION_CLAMP, POSITION_CLAMP)
      end
      coords.position = vec3(x, y, z)
      local ped = PlayerPedId()
      AttachEntityToEntity(Sling.object, ped, GetPedBoneIndex(ped, selectData.boneId),
        coords.position.x, coords.position.y, coords.position.z,
        coords.rotation.x, coords.rotation.y, coords.rotation.z,
        true, true, false, true, 2, true)
    end

    local function updateRotation(axis, delta)
      local x, y, z = coords.rotation.x, coords.rotation.y, coords.rotation.z
      if axis == 'x' then
        x = x + delta
      elseif axis == 'y' then
        y = y + delta
      elseif axis == 'z' then
        z = z + delta
      end
      coords.rotation = vec3(x, y, z)
      local ped = PlayerPedId()
      AttachEntityToEntity(Sling.object, ped, GetPedBoneIndex(ped, selectData.boneId),
        coords.position.x, coords.position.y, coords.position.z,
        coords.rotation.x, coords.rotation.y, coords.rotation.z,
        true, true, false, true, 2, true)
    end

    while Sling.inPositioning do
      if not DoesEntityExist(Sling.object) then
        if not HasModelLoaded(selectData.weapon) and not pcall(lib.requestModel, selectData.weapon) then
          Sling.inPositioning = false
          lib.hideTextUI()
          lib.print.warn(("Can't position %s: model failed to load"):format(tostring(selectData.weaponName)))
          break
        end

        Sling.object = CreateObject(selectData.weapon, 0, 0, 0, false, true, false)
        local ped = PlayerPedId()
        AttachEntityToEntity(Sling.object, ped, GetPedBoneIndex(ped, selectData.boneId), coords.position.x,
          coords.position.y, coords.position.z, coords.rotation.x, coords.rotation.y, coords.rotation.z, true, true,
          false, true, 2, true)
        SetEntityCollision(Sling.object, false, false)
      end

      -- ENTER Handle control inputs for positioning
      if IsDisabledControlJustPressed(0, 18) then
        Sling:OnPositioningDone(coords, selectData)
        break
      end

      -- Backspace cancel
      if IsDisabledControlJustPressed(0, 177) then
        DeleteObject(Sling.object)
        Sling.inPositioning = false
        lib.hideTextUI()
        SetModelAsNoLongerNeeded(selectData.weapon)
        break
      end

      if IsDisabledControlPressed(0, 21) then
        speed = FAST_SPEED
      end

      if IsDisabledControlReleased(0, 21) then
        speed = DEFAULT_SPEED
      end

      if IsDisabledControlPressed(0, 44) then updatePosition('x', -speed) end
      if IsDisabledControlPressed(0, 46) then updatePosition('x', speed) end
      if IsDisabledControlPressed(0, 188) then updatePosition('y', speed) end
      if IsDisabledControlPressed(0, 187) then updatePosition('y', -speed) end
      if IsDisabledControlPressed(0, 189) then updatePosition('z', speed) end
      if IsDisabledControlPressed(0, 190) then updatePosition('z', -speed) end
      if IsDisabledControlPressed(0, 96) then updateRotation('x', speed + 1.0) end
      if IsDisabledControlPressed(0, 97) then updateRotation('x', -(speed + 1.0)) end
      if IsDisabledControlPressed(0, 48) then updateRotation('z', speed + 1.0) end
      if IsDisabledControlPressed(0, 73) then updateRotation('z', -(speed + 1.0)) end
      if IsDisabledControlPressed(0, 47) then updateRotation('y', speed + 1.0) end
      if IsDisabledControlPressed(0, 74) then updateRotation('y', -(speed + 1.0)) end

      local text = ("pos: (%.2f, %.2f, %.2f) | rot: (%.2f, %.2f, %.2f)"):format(coords.position.x, coords.position.y,
        coords.position.z, coords.rotation.x, coords.rotation.y, coords.rotation.z)
      lib.showTextUI((locale("currentPosition") .. ": %s"):format(text) ..
        '  \n  ' ..
        '[QE]    - ' ..
        locale("up") ..
        '/' ..
        locale("down") ..
        '  \n' ..
        '[Arrows] - ' ..
        locale("move") ..
        ', XY  \n' ..
        '[Scroll]- ' ..
        locale("rotate") ..
        '  \n' ..
        '[XZ]- ' ..
        locale("rotate") ..
        '  \n' ..
        '[GH]    - ' ..
        locale("rotate") ..
        ' Z  \n' ..
        '[Shift] - ' ..
        locale("speed") .. '  \n' .. '[ENTER] - ' .. locale("confirm") .. '  \n' .. '[BACKSPACE] - ' .. locale("cancel"))

      DisableControls()

      Wait(4)
    end
  end)
end

exports("StartPositioning", function(selectData)
  if Sling.inPositioning then return end
  -- Personal position unless explicitly asked for a preset (the server checks the permission)
  Sling.isPreset = type(selectData) == "table" and selectData.isPreset == true
  Sling:StartPositioning(selectData)
end)

function Sling:StartConfiguration(isPreset)
  -- The menu is registered once the player has loaded
  if Sling.inPositioning or #menuWeapons == 0 then return end
  Sling.isPreset = isPreset == true

  -- Preselect the weapon in hand when it's configured
  local selectedWeapon = GetSelectedPedWeapon(cache.ped)
  for index, weaponName in ipairs(menuWeapons) do
    if Config.Weapons[weaponName].name == selectedWeapon then
      selectWeapon(index)
      break
    end
  end

  lib.setMenuOptions('sling_select', {
    label = 'Bone', values = menuBones, args = menuBones, defaultIndex = selectData.boneIndex
  }, 1)
  lib.setMenuOptions('sling_select', {
    label = 'Weapon', values = menuWeapons, args = menuWeapons, defaultIndex = selectData.weaponIndex
  }, 2)
  lib.showMenu('sling_select')
end

exports("StartConfiguration", function(isPreset)
  Sling:StartConfiguration(isPreset)
end)

function Sling:InitCommands()
  Debug("info", "Initializing commands")
  -- false for regular players, otherwise the admin type (e.g. "global")
  local admin = lib.callback.await("force-sling:callback:isPlayerAdmin", false)

  local function hasPermission(permission)
    return permission == "any" or (admin and admin == permission)
  end

  RegisterCommand(Config.Command.name, function(source, args, raw)
    if not hasPermission(Config.Command.permission) then return end
    Sling:StartConfiguration(false)
  end, false)

  RegisterCommand(Config.Command.reset, function(source, args, raw)
    if not hasPermission(Config.Command.permission) then return end
    local weapon = args[1] and args[1]:lower() or GetSelectedPedWeapon(cache.ped)
    if type(weapon) == "number" then
      for weaponName, weaponVal in pairs(Sling.cachedWeapons) do
        if weaponVal.name == weapon then
          weapon = weaponName
          break
        end
      end
    end
    local ok, positions = pcall(lib.callback.await, "force-sling:callback:resetWeaponPositions", false, weapon)
    if ok and type(positions) == "table" then
      Sling.cachedPositions = NormalizePositions(positions)
    end
    Utils:DeleteWeapon(weapon)
  end, false)

  RegisterCommand(Config.Presets.command, function(source, args, raw)
    if not hasPermission(Config.Presets.permission) then return end
    Sling:StartConfiguration(true)
  end, false)

  if hasPermission(Config.Command.permission) then
    TriggerEvent("chat:addSuggestion", "/" .. Config.Command.name, locale("commandSling"))
    TriggerEvent("chat:addSuggestion", "/" .. Config.Command.reset, locale("commandReset"), {
      { name = "weapon", help = locale("commandResetWeapon") }
    })
  end
  if hasPermission(Config.Presets.permission) then
    TriggerEvent("chat:addSuggestion", "/" .. Config.Presets.command, locale("commandPreset"))
  end

  Debug("info", "Commands initialized")
end

