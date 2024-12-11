Sling = {
  isPreset = false,

  cachedPositions = {},
  cachedPresets = {},
  cachedWeapons = {},
  cachedAttachments = {},

  inPositioning = false,
  data = {
    weapon = nil,
    weaponName = nil,
    weaponHash = nil,
    boneId = nil,

    object = nil,
  }
}

--- Initializes the main functionality of Sling.
function Sling:InitMain()
  Sling:Debug("info", "Initializing main thread")

  Sling:InitSling()
  Sling:InitCommands()

  Sling:Debug("info", "Main thread initialized")
end

--- Initializes the Sling functionality.
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

  lib.registerMenu({
    id = 'sling_select',
    title = locale("slingConfig"),
    position = 'top-right',
    onSideScroll = function(selected, scrollIndex, args)
      if selected == 1 then
        for key, val in pairs(Config.Bones) do
          if key == args[scrollIndex] then
            Sling.data.boneId = val
            break
          end
        end
      elseif selected == 2 then
        for key, val in pairs(Config.Weapons) do
          if key == args[scrollIndex] then
            Sling.data.weapon = val.model
            Sling.data.weaponName = key
            Sling.data.weaponHash = val.name
            break
          end
        end
      end
    end,
    onSelected = function(selected, secondary, args)
      -- Add any additional logic for when an option is selected
    end,
    onClose = function(keyPressed)
      Sling.inPositioning = false
    end,
    options = {
      { label = 'Bone',    values = loadBoneOptions(),   args = loadBoneOptions() },
      { label = 'Weapon',  values = loadWeaponOptions(), args = loadWeaponOptions() },
      { label = 'Continue' },
    }
  }, function(selected, scrollIndex, args)
    if not Sling.data.weapon or not Sling.data.weaponName or not Sling.data.boneId then
      Sling.data.weapon = `w_pi_pistol50`
      Sling.data.weaponName = "weapon_pistol50"
      Sling.data.boneId = 24816
    end
    Sling:Debug("info", "Selected weapon: " .. Sling.data.weapon)
    Sling:Debug("info", "Selected bone: " .. Sling.data.boneId)
    Sling:StartPositioning()
  end)
end

--- Thread to handle weapon attachment and positioning.
function Sling:WeaponThread()
  CreateThread(function()
    while true do
      local playerPed = PlayerPedId()
      local weapon = GetSelectedPedWeapon(playerPed)
      for weaponName, weaponVal in pairs(Sling.cachedWeapons) do
        if not Sling.cachedAttachments[weaponName] then
          Sling.cachedAttachments[weaponName] = {}
        end
        if weapon == weaponVal.name then
          if DoesEntityExist(Sling.cachedAttachments[weaponName].obj) then
            DeleteEntity(Sling.cachedAttachments[weaponName].obj)
          end
        else
          if Sling.cachedPositions[weaponName] and not DoesEntityExist(Sling.cachedAttachments[weaponName].obj) then
            local coords = Sling.cachedPositions[weaponName]
            local weaponObject = CreateWeaponObject(weaponVal.name, 0, coords.coords.x, coords.coords.y, coords.coords.z,
              true, 1.0, 0)
            for _, component in pairs(weaponVal.attachments) do
              GiveWeaponComponentToWeaponObject(weaponObject, component)
            end

            AttachEntityToEntity(weaponObject, playerPed, GetPedBoneIndex(playerPed, (coords.boneId or 24816)),
              coords.coords.x, coords.coords.y, coords.coords.z, coords.rot.x, coords.rot.y, coords.rot.z, true, true,
              false, true, 2, true)
            Sling.cachedAttachments[weaponName].obj = weaponObject
          end

          if not Sling.cachedPositions[weaponName] and Sling.cachedPresets[weaponName] and not DoesEntityExist(Sling.cachedAttachments[weaponName].obj) then
            local coords = Sling.cachedPresets[weaponName]
            local weaponObject = CreateWeaponObject(weaponVal.name, 0, coords.coords.x, coords.coords.y, coords.coords.z,
              true, 1.0, 0)
            for _, component in pairs(weaponVal.attachments) do
              GiveWeaponComponentToWeaponObject(weaponObject, component)
            end
            AttachEntityToEntity(weaponObject, playerPed, GetPedBoneIndex(playerPed, (coords.boneId or 24816)),
              coords.coords.x, coords.coords.y, coords.coords.z, coords.rot.x, coords.rot.y, coords.rot.z, true, true,
              false, true, 2, true)
            Sling.cachedAttachments[weaponName].obj = weaponObject
          end

          if not Sling.cachedPositions[weaponName] and not Sling.cachedPresets[weaponName] and not DoesEntityExist(Sling.cachedAttachments[weaponName].obj) then
            local weaponObject = CreateWeaponObject(weaponVal.name, 0, 0.0, 0.0, 0.0, true, 1.0, 0)
            for _, component in pairs(weaponVal.attachments) do
              GiveWeaponComponentToWeaponObject(weaponObject, component)
            end
            AttachEntityToEntity(weaponObject, playerPed, GetPedBoneIndex(playerPed, 24816), 0.0, -0.15, 0.0, 0.0, 0.0,
              0.0, true, true, false, true, 2, true)
            Sling.cachedAttachments[weaponName].obj = weaponObject
          end
        end
      end

      Wait(1000)
    end
  end)
end

--- Handles the completion of positioning.
function Sling:OnPositioningDone(coords)
  lib.hideTextUI()
  Sling.inPositioning = false
  local weapon = Sling.data.weapon
  coords.position = vector3(coords.position.x, coords.position.y, coords.position.z)
  local distanceFromMiddle = #(coords.position - vector3(0.0, 0.0, 0.0))
  local distanceFromMiddle2 = #(coords.position - vector3(0.0, 0.0, -0.2))
  local distanceFromMiddle3 = #(coords.position - vector3(0.0, 0.0, 0.2))
  if distanceFromMiddle < 0.14 or distanceFromMiddle2 < 0.14 or distanceFromMiddle3 < 0.14 then
    coords.position = vector3(coords.position.x, 0.17, coords.position.z)
  end
  TriggerServerEvent("force-sling:server:saveWeaponPosition", coords.position, coords.rotation, weapon,
    Sling.data.weaponName, Sling.data.boneId, Sling.isPreset)
  Sling.cachedPositions[Sling.data.weaponName] = {
    coords = coords.position,
    rot = coords.rotation
  }
  if Sling.cachedAttachments[Sling.data.weaponName] then
    if DoesEntityExist(Sling.cachedAttachments[Sling.data.weaponName].obj) then
      DeleteEntity(Sling.cachedAttachments[Sling.data.weaponName].obj)
    end
  end
  DeleteEntity(Sling.object)
end

--- Disables specific controls during positioning.
local function DisableControls()
  local controls = { 25, 44, 45, 51, 140, 141, 143, 263, 264, 24, 96, 97, 47, 74 }
  for _, control in ipairs(controls) do
    DisableControlAction(0, control, true)
  end
end

--- Starts the positioning process for the weapon.
function Sling:StartPositioning()
  if Sling.inPositioning then return end
  local function vector3(x, y, z)
    return { x = x, y = y, z = z }
  end

  Sling.inPositioning = true
  CreateThread(function()
    local speed = 0.001
    local coords = {
      position = vector3(0.0, 0.0, 0.0),
      rotation = vector3(0.0, 0.0, 0.0)
    }
    while Sling.inPositioning do
      local playerPed = PlayerPedId()
      if not DoesEntityExist(Sling.object) then
        if not HasModelLoaded(Sling.data.weapon) then
          RequestModel(Sling.data.weapon)
          while not HasModelLoaded(Sling.data.weapon) do
            Wait(100)
          end
        end

        Sling.object = CreateObject(Sling.data.weapon, 0, 0, 0, false, true, false)
        AttachEntityToEntity(Sling.object, playerPed, GetPedBoneIndex(playerPed, Sling.data.boneId), coords.position.x,
          coords.position.y, coords.position.z, coords.rotation.x, coords.rotation.y, coords.rotation.z, true, true,
          false, true, 2, true)
        SetEntityCollision(Sling.object, false, false)
      end

      -- Handle control inputs for positioning
      if IsDisabledControlJustReleased(0, 176) then
        Sling:OnPositioningDone(coords)
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

        AttachEntityToEntity(Sling.object, playerPed, GetPedBoneIndex(playerPed, Sling.data.boneId), coords.position.x,
          coords.position.y, coords.position.z, coords.rotation.x, coords.rotation.y, coords.rotation.z, true, true,
          false, true, 2, true)
      end

      local function updateRotation(axis, delta)
        coords.rotation = vector3(coords.rotation.x, coords.rotation.y, coords.rotation.z)
        coords.rotation[axis] = coords.rotation[axis] + delta
        AttachEntityToEntity(Sling.object, playerPed, GetPedBoneIndex(playerPed, Sling.data.boneId), coords.position.x,
          coords.position.y, coords.position.z, coords.rotation.x, coords.rotation.y, coords.rotation.z, true, true,
          false, true, 2, true)
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
        '[GH]    - ' ..
        locale("rotate") ..
        ' Z  \n' .. '[Shift] - ' .. locale("speed") .. '  \n' .. '[ENTER] - ' .. locale("confirm") .. '  \n')

      DisableControls()

      Wait(4)
    end
  end)
end

--- Starts the configuration menu for Sling.
function Sling:StartConfiguration(isPreset)
  Sling.isPreset = isPreset
  lib.showMenu('sling_select')
end

--- Initializes commands based on the configuration.
function Sling:InitCommands()
  Sling:Debug("info", "Initializing commands")
  local admin = lib.callback.await("force-Sling:callback:isPlayerAdmin", false)
  if Config.Debug or admin.isAdmin then
    RegisterCommand(Config.Command.name, function(source, args, raw)
      if Config.Command.permission ~= "any" and not admin.adminType == Config.Command.permission then return end
      Sling:StartConfiguration(false)
    end, false)

    RegisterCommand(Config.Presets.command, function(source, args, raw)
      if Config.Presets.permission ~= "any" and not admin.adminType == Config.Presets.permission then return end
      Sling:StartConfiguration(true)
    end, false)
  end

  Sling:Debug("info", "Commands initialized")
end

--- Debug function to print messages based on the type.
---@param type string The type of the debug message (error, warn, info, verbose, debug).
---@param message string The debug message to print.
function Sling:Debug(type, message)
  if not Config.Debug then return end
  lib.print[type](message)
end
