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
  Sling.cachedPositions = lib.callback.await("force-sling:callback:getCachedPositions", false)
  Sling.cachedPresets = lib.callback.await("force-sling:callback:getCachedPresets", false)
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
    boneId = 24816,
    weapon = `w_pi_pistol50`,
    weaponName = "weapon_pistol50"
  }

  lib.registerMenu({
    id = 'sling_select',
    title = locale("slingConfig"),
    position = 'top-right',
    onSideScroll = function(selected, scrollIndex, args)
      if selected == 1 then
        for key, val in pairs(Config.Bones) do
          if key == args[scrollIndex] then
            selectData.boneId = val
            break
          end
        end
      elseif selected == 2 then
        for key, val in pairs(Config.Weapons) do
          if key == args[scrollIndex] then
            selectData.weapon = val.model
            selectData.weaponName = key
            break
          end
        end
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
  -- Extremely weird fix for the networking issue when createweaponobject is lagging on player attachment
  local function createAndAttachWeapon(weaponName, weaponVal, coords, playerPed)
    if Sling.currentAttachedAmount >= Config.MaxWeaponsAttached then return end
    local weaponObject = CreateWeaponObject(weaponVal.name, 0, coords.coords.x, coords.coords.y, coords.coords.z, true,
      1.0, 0)
    for _, component in pairs(weaponVal.attachments) do
      GiveWeaponComponentToWeaponObject(weaponObject, component)
    end
    lib.requestModel(weaponVal.model)
    local placeholder = CreateObjectNoOffset(weaponVal.model, coords.coords.x, coords.coords.y, coords.coords.z, true,
      true,
      false)
    SetEntityVisible(placeholder, false, false)
    AttachEntityToEntity(placeholder, playerPed, GetPedBoneIndex(playerPed, (coords.boneId or 24816)),
      coords.coords.x, coords.coords.y, coords.coords.z, coords.rot.x, coords.rot.y, coords.rot.z, true, true, false,
      true, 2, true)
    AttachEntityToEntity(weaponObject, placeholder, GetEntityBoneIndexByName(placeholder, "gun_root"), 0.0, 0.0, 0.0,
      0.0,
      0.0,
      0.0,
      true, true, false, true, 2, true)
    -- NetworkRegisterEntityAsNetworked(weaponObject)
    Sling.cachedAttachments[weaponName].obj = weaponObject
    Sling.cachedAttachments[weaponName].placeholder = placeholder
    Sling.currentAttachedAmount = Sling.currentAttachedAmount + 1
  end

  local function deleteWeapon(weaponName)
    NetworkUnregisterNetworkedEntity(Sling.cachedAttachments[weaponName].obj)
    DeleteObject(Sling.cachedAttachments[weaponName].obj)
    DetachEntity(Sling.cachedAttachments[weaponName].placeholder, true, false)
    DeleteObject(Sling.cachedAttachments[weaponName].placeholder)
    Sling.currentAttachedAmount = Sling.currentAttachedAmount - 1
  end

  CreateThread(function()
    while true do
      local playerPed = PlayerPedId()
      local weapon = GetSelectedPedWeapon(playerPed)
      while Sling.inPositioning do
        Wait(1000)
      end

      for weaponName, weaponVal in pairs(Sling.cachedWeapons) do
        if not Sling.cachedAttachments[weaponName] then
          Sling.cachedAttachments[weaponName] = {}
        end

        if weapon == weaponVal.name then
          if DoesEntityExist(Sling.cachedAttachments[weaponName].obj) then
            deleteWeapon(weaponName)
          end
        else
          if not DoesEntityExist(Sling.cachedAttachments[weaponName].obj) then
            local coords = Sling.cachedPositions[weaponName] or Sling.cachedPresets[weaponName] or
                { coords = { x = 0.0, y = -0.15, z = 0.0 }, rot = { x = 0.0, y = 0.0, z = 0.0 }, boneId = 24816 }
            createAndAttachWeapon(weaponName, weaponVal, coords, playerPed)
          else
            if not IsEntityAttachedToAnyPed(Sling.cachedAttachments[weaponName].placeholder) then
              deleteWeapon(weaponName)
            end
          end
        end
      end

      Wait(1000)
    end
  end)
end

function Sling:OnPositioningDone(coords, selectData)
  lib.hideTextUI()
  Sling.inPositioning = false
  local weapon = selectData.weapon
  coords.position = vector3(coords.position.x, coords.position.y, coords.position.z)
  local distanceFromMiddle = #(coords.position - vector3(0.0, 0.0, 0.0))
  local distanceFromMiddle2 = #(coords.position - vector3(0.0, 0.0, -0.2))
  local distanceFromMiddle3 = #(coords.position - vector3(0.0, 0.0, 0.2))
  if distanceFromMiddle < 0.14 or distanceFromMiddle2 < 0.14 or distanceFromMiddle3 < 0.14 then
    coords.position = vector3(coords.position.x, 0.17, coords.position.z)
  end
  TriggerServerEvent("force-sling:server:saveWeaponPosition", coords.position, coords.rotation, weapon,
    selectData.weaponName, selectData.boneId, Sling.isPreset)
  Sling.cachedPositions[selectData.weaponName] = {
    coords = coords.position,
    rot = coords.rotation,
    boneId = selectData.boneId
  }
  if Sling.cachedAttachments[selectData.weaponName] then
    if DoesEntityExist(Sling.cachedAttachments[selectData.weaponName].obj) then
      DeleteEntity(Sling.cachedAttachments[selectData.weaponName].obj)
    end
  end
  DeleteEntity(Sling.object)
end

local function DisableControls()
  local controls = { 25, 44, 45, 51, 140, 141, 143, 263, 264, 24, 96, 97, 47, 74, 177 }
  for _, control in ipairs(controls) do
    DisableControlAction(0, control, true)
  end
end

--- @param selectData table
function Sling:StartPositioning(selectData)
  if Sling.inPositioning then return end
  local coords = {
    position = vector3(0.0, 0.0, 0.0),
    rotation = vector3(0.0, 0.0, 0.0)
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

  local function vector3(x, y, z)
    return { x = x, y = y, z = z }
  end

  Sling.inPositioning = true
  CreateThread(function()
    local speed = 0.001
    while Sling.inPositioning do
      local playerPed = PlayerPedId()
      if not DoesEntityExist(Sling.object) then
        if not HasModelLoaded(selectData.weapon) then
          RequestModel(selectData.weapon)
          while not HasModelLoaded(selectData.weapon) do
            Wait(100)
          end
        end

        Sling.object = CreateObject(selectData.weapon, 0, 0, 0, false, true, false)
        AttachEntityToEntity(Sling.object, playerPed, GetPedBoneIndex(playerPed, selectData.boneId), coords.position.x,
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
        speed = 0.01
      end

      if IsDisabledControlReleased(0, 21) then
        speed = 0.001
      end

      local function updatePosition(axis, delta)
        coords.position = vector3(coords.position.x, coords.position.y, coords.position.z)
        coords.position[axis] = lib.math.clamp(coords.position[axis] + delta, -0.2, 0.2)

        AttachEntityToEntity(Sling.object, playerPed, GetPedBoneIndex(playerPed, selectData.boneId), coords.position.x,
          coords.position.y, coords.position.z, coords.rotation.x, coords.rotation.y, coords.rotation.z, true, true,
          false, true, 2, true)
      end

      local function updateRotation(axis, delta)
        coords.rotation = vector3(coords.rotation.x, coords.rotation.y, coords.rotation.z)
        coords.rotation[axis] = coords.rotation[axis] + delta
        AttachEntityToEntity(Sling.object, playerPed, GetPedBoneIndex(playerPed, selectData.boneId), coords.position.x,
          coords.position.y, coords.position.z, coords.rotation.x, coords.rotation.y, coords.rotation.z, true, true,
          false, true, 2, true)
      end

      -- TODO: fix so all bones have the same controls
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
      local weapon = args[1] and args[1]:lower() or GetSelectedPedWeapon(PlayerPedId())
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

---@param type string The type of the debug message (error, warn, info, verbose, debug).
---@param message string The debug message to print.
function Sling:Debug(type, message)
  if not Config.Debug then return end
  lib.print[type](message)
end
