Utils = {}

local skippedWeapons = {}
local maxWarned = {}

--- Loads the prop model and weapon asset. Addon weapons aren't preloaded like base game weapons,
--- and a wrong model in Config.Weapons would otherwise throw and stop the whole weapon thread.
--- @return boolean
local LOAD_TIMEOUT_MS = 5000
local LOAD_RETRY_MS = 60000

function Utils:LoadWeaponAssets(weaponName, weaponVal)
  local skipped = skippedWeapons[weaponName]
  if skipped == true or (skipped and GetGameTimer() < skipped) then return false end

  --- @param retry boolean A streaming timeout is retried later; a model that doesn't exist never is
  local function skip(reason, retry)
    skippedWeapons[weaponName] = retry and GetGameTimer() + LOAD_RETRY_MS or true
    lib.print.warn(("Skipping %s: %s. Check its entry in Config.Weapons and that the addon weapon is streamed.")
      :format(weaponName, reason))
    return false
  end

  if not weaponVal.model or not IsModelInCdimage(weaponVal.model) then
    return skip("model not found")
  end
  -- lib.requestModel throws on timeout (30 s by default); a shorter timeout keeps the weapon tick responsive
  if not pcall(lib.requestModel, weaponVal.model, LOAD_TIMEOUT_MS) then
    return skip("model failed to load", true)
  end

  RequestWeaponAsset(weaponVal.name, 31, 0)
  local timeout = GetGameTimer() + LOAD_TIMEOUT_MS
  while not HasWeaponAssetLoaded(weaponVal.name) and GetGameTimer() < timeout do
    Wait(10)
  end
  if not HasWeaponAssetLoaded(weaponVal.name) then
    SetModelAsNoLongerNeeded(weaponVal.model)
    return skip("weapon asset failed to load", true)
  end

  skippedWeapons[weaponName] = nil
  return true
end

function Utils:CreateAndAttachWeapon(weaponName, weaponVal, coords, playerPed)
  if Sling.currentAttachedAmount >= Config.MaxWeaponsAttached then
    -- Called every tick for every weapon that doesn't fit, so only warn once per weapon
    if not maxWarned[weaponName] then
      maxWarned[weaponName] = true
      Debug("warn", ("Max weapons attached reached (%d), not showing %s"):format(Config.MaxWeaponsAttached, weaponName))
    end
    return false
  end
  maxWarned[weaponName] = nil

  if not weaponVal or not weaponVal.name then
    Debug("error", "Invalid weapon data")
    return false
  end

  if not self:LoadWeaponAssets(weaponName, weaponVal) then
    return false
  end

  local weaponObject = CreateWeaponObject(weaponVal.name, 0, coords.coords.x, coords.coords.y, coords.coords.z, true, 1.0,
    0)
  if not weaponObject or weaponObject == 0 then
    Debug("error", "Failed to create weapon object")
    return false
  end

  if NetworkGetEntityIsNetworked(weaponObject) then
    NetworkUnregisterNetworkedEntity(weaponObject)
  end
  SetEntityCollision(weaponObject, false, false)
  for _, component in pairs(weaponVal.attachments or {}) do
    GiveWeaponComponentToWeaponObject(weaponObject, component)
  end
  -- The placeholder is networked because it is what other players see. Servers with
  -- sv_entityLockdown block client-created networked entities; fall back to a local one so the
  -- player at least sees their own sling.
  local placeholder = CreateObjectNoOffset(weaponVal.model, coords.coords.x, coords.coords.y, coords.coords.z, true,
    true, false)
  if not placeholder or placeholder == 0 or not DoesEntityExist(placeholder) then
    placeholder = CreateObjectNoOffset(weaponVal.model, coords.coords.x, coords.coords.y, coords.coords.z, false,
      true, false)
  end
  SetEntityCollision(placeholder, false, false)
  SetEntityAlpha(placeholder, 0, false)
  AttachEntityToEntity(placeholder, playerPed, GetPedBoneIndex(playerPed, (coords.boneId or DEFAULT_BONE)),
    coords.coords.x, coords.coords.y, coords.coords.z, coords.rot.x, coords.rot.y, coords.rot.z, true, true, false,
    true, 2, true)
  -- Addon weapon models don't always have a gun_root bone
  local gunRoot = GetEntityBoneIndexByName(placeholder, "gun_root")
  AttachEntityToEntity(weaponObject, placeholder, gunRoot ~= -1 and gunRoot or 0, 0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, true, true, false, true, 2, true)
  Sling.cachedAttachments[weaponName] = { obj = weaponObject, placeholder = placeholder }
  Sling.currentAttachedAmount = Sling.currentAttachedAmount + 1
  SetModelAsNoLongerNeeded(weaponVal.model)

  return true
end

--- Deletes a slung weapon prop. This is the only place that removes attachments,
--- so currentAttachedAmount always matches the number of cachedAttachments entries.
function Utils:DeleteWeapon(weaponName)
  local attachment = Sling.cachedAttachments[weaponName]
  if not attachment then return end

  if DoesEntityExist(attachment.obj) then
    if NetworkGetEntityIsNetworked(attachment.obj) then
      NetworkUnregisterNetworkedEntity(attachment.obj)
    end
    DeleteObject(attachment.obj)
  end
  if DoesEntityExist(attachment.placeholder) then
    if IsEntityAttachedToAnyPed(attachment.placeholder) then
      DetachEntity(attachment.placeholder, true, false)
    end
    DeleteObject(attachment.placeholder)
  end

  Sling.cachedAttachments[weaponName] = nil
  Sling.currentAttachedAmount = math.max(Sling.currentAttachedAmount - 1, 0)
end
