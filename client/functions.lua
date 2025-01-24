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
  Sling:Debug("info", "Initializing main thread")

  Sling:InitSling()
  Sling:InitCommands()

  Sling:Debug("info", "Main thread initialized")
end

function Sling:InitSling()
  local libCallbackAwait = lib.callback.await
  Sling.cachedPositions = libCallbackAwait("force-sling:callback:getCachedPositions", false)
  Sling.cachedPresets = libCallbackAwait("force-sling:callback:getCachedPresets", false)
  Sling.cachedWeapons = Inventory:GetWeapons()
  Sling:WeaponThread()

  local function loadBoneOptions()
    local bones = {}
    for boneName, _ in pairs(Config.Bones) do
      table.insert(bones, boneName)
    end
    return bones
  end

  local function loadWeaponOptions()
    local weapons = {}
    for weaponName, _ in pairs(Config.Weapons) do
      table.insert(weapons, weaponName)
    end
    return weapons
  end

  local bones = loadBoneOptions()
  local weapons = loadWeaponOptions()

  local selectData = {
    boneId = DEFAULT_BONE,
    weapon = `w_pi_pistol50`,
    weaponName = "weapon_pistol50"
  }

  lib.registerMenu({
    id = 'sling_select',
    title = locale("slingConfig"),
    position = 'top-right',
    onSideScroll = function(selected, scrollIndex, args)
      if selected == 1 then
        selectData.boneId = Config.Bones[args[scrollIndex]]
      elseif selected == 2 then
        local weapon = Config.Weapons[args[scrollIndex]]
        selectData.weapon = weapon.model
        selectData.weaponName = args[scrollIndex]
      end
    end,
    onSelected = function(selected, secondary, args)
    end,
    onClose = function(keyPressed)
      Sling.inPositioning = false
    end,
    options = {
      { label = 'Bone',    values = bones,   args = bones },
      { label = 'Weapon',  values = weapons, args = weapons },
      { label = 'Continue' },
    }
  }, function(selected, scrollIndex, args)
    Sling:Debug("info", "Selected weapon: " .. selectData.weapon)
    Sling:Debug("info", "Selected bone: " .. selectData.boneId)
    Sling:StartPositioning(selectData)
  end)
end

function Sling:WeaponThread()
  local function handleWeaponAttachment(weaponName, weaponVal, playerPed, weapon)
    if not Sling.cachedAttachments[weaponName] then
      Sling.cachedAttachments[weaponName] = {}
    end

    if weapon == weaponVal.name then
      if DoesEntityExist(Sling.cachedAttachments[weaponName].obj) then
        Utils:DeleteWeapon(weaponName)
      end
    else
      if not DoesEntityExist(Sling.cachedAttachments[weaponName].obj) then
        local coords = Sling.cachedPositions[weaponName] or Sling.cachedPresets[weaponName] or
            { coords = { x = 0.0, y = -0.15, z = 0.0 }, rot = { x = 0.0, y = 0.0, z = 0.0 }, boneId = DEFAULT_BONE }
        Utils:CreateAndAttachWeapon(weaponName, weaponVal, coords, playerPed)
      else
        if not IsEntityAttachedToAnyPed(Sling.cachedAttachments[weaponName].placeholder) then
          Utils:DeleteWeapon(weaponName)
        end
      end
    end
  end

  CreateThread(function()
    while true do
      local weapon = GetSelectedPedWeapon(cache.ped)
      while Sling.inPositioning do
        Wait(1000)
      end

      for weaponName, weaponVal in pairs(Sling.cachedWeapons) do
        handleWeaponAttachment(weaponName, weaponVal, cache.ped, weapon)
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
  Sling.cachedPositions[selectData.weaponName] = {
    coords = coords.position,
    rot = coords.rotation,
    boneId = selectData.boneId
  }
  if Sling.cachedAttachments[selectData.weaponName] then
    if DoesEntityExist(Sling.cachedAttachments[selectData.weaponName].obj) or DoesEntityExist(Sling.cachedAttachments[selectData.weaponName].placeholder) then
      DeleteEntity(Sling.cachedAttachments[selectData.weaponName].obj)
      DeleteEntity(Sling.cachedAttachments[selectData.weaponName].placeholder)
    end
  end
  DeleteEntity(Sling.object)
end

local function DisableControls()
  -- Cache controls table outside function
  local controls = {
    25, 44, 45, 51, 140, 141, 143,
    263, 264, 24, 96, 97, 47, 74, 177
  }
  for i = 1, #controls do -- Use numeric for loop
    DisableControlAction(0, controls[i], true)
  end
end

function Sling:StartPositioning(selectData)
  if Sling.inPositioning then return end
  local function vector3(x, y, z)
    return { x = x or 0, y = y or 0, z = z or 0 }
  end
  local coords = {
    position = vec3(0.0, 0.0, 0.0),
    rotation = vec3(0.0, 0.0, 0.0)
  }

  if Sling.cachedAttachments[selectData.weaponName] and DoesEntityExist(Sling.cachedAttachments[selectData.weaponName].obj) then
    DeleteEntity(Sling.cachedAttachments[selectData.weaponName].obj)
  end
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
      coords.position[axis] = lib.math.clamp(coords.position[axis] + delta, -POSITION_CLAMP, POSITION_CLAMP)
      AttachEntityToEntity(Sling.object, cache.ped, GetPedBoneIndex(cache.ped, selectData.boneId),
        coords.position.x, coords.position.y, coords.position.z, coords.rotation.x, coords.rotation.y, coords.rotation.z,
        true, true, false, true, 2, true)
    end

    local function updateRotation(axis, delta)
      coords.rotation[axis] = coords.rotation[axis] + delta
      AttachEntityToEntity(Sling.object, cache.ped, GetPedBoneIndex(cache.ped, selectData.boneId),
        coords.position.x, coords.position.y, coords.position.z, coords.rotation.x, coords.rotation.y, coords.rotation.z,
        true, true, false, true, 2, true)
    end

    while Sling.inPositioning do
      if not DoesEntityExist(Sling.object) then
        if not HasModelLoaded(selectData.weapon) then
          RequestModel(selectData.weapon)
          while not HasModelLoaded(selectData.weapon) do
            Wait(100)
          end
        end

        Sling.object = CreateObject(selectData.weapon, 0, 0, 0, false, true, false)
        AttachEntityToEntity(Sling.object, cache.ped, GetPedBoneIndex(cache.ped, selectData.boneId), coords.position.x,
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
        DeleteEntity(Sling.object)
        Sling.inPositioning = false
        lib.hideTextUI()
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

function Sling:StartConfiguration(isPreset)
  Sling.isPreset = isPreset
  lib.showMenu('sling_select')
end

function Sling:InitCommands()
  Sling:Debug("info", "Initializing commands")
  local admin = lib.callback.await("force-Sling:callback:isPlayerAdmin", false)
  if Config.Debug or admin.isAdmin then
    RegisterCommand(Config.Command.name, function(source, args, raw)
      if Config.Command.permission ~= "any" and not admin.adminType == Config.Command.permission then return end
      Sling:StartConfiguration(false)
    end, false)

    RegisterCommand(Config.Command.reset, function(source, args, raw)
      if Config.Command.permission ~= "any" and not admin.adminType == Config.Command.permission then return end
      local weapon = args[1] and args[1]:lower() or GetSelectedPedWeapon(cache.ped)
      if type(weapon) == "number" then
        for weaponName, weaponVal in pairs(Sling.cachedWeapons) do
          if weaponVal.name == weapon then
            weapon = weaponName
            break
          end
        end
      end
      Sling.cachedPositions = lib.callback.await("force-sling:callback:resetWeaponPositions", false, weapon)
    end, false)

    RegisterCommand(Config.Presets.command, function(source, args, raw)
      if Config.Presets.permission ~= "any" and not admin.adminType == Config.Presets.permission then return end
      Sling:StartConfiguration(true)
    end, false)
  end

  Sling:Debug("info", "Commands initialized")
end

function Sling:Debug(type, message)
  if not Config.Debug then return end
  local func = lib.print[type] or lib.print.info
  func(message)
end
