function IsResourceStartingOrStarted(resource)
  return GetResourceState(resource) == "starting" or GetResourceState(resource) == "started"
end

function Debug(level, message, ...)
  if not Config.Debug then return end

  local levels = {
    error = function(msg) lib.print.error(msg) end,
    warn = function(msg) lib.print.warn(msg) end,
    info = function(msg) lib.print.info(msg) end,
    debug = function(msg) lib.print.debug(msg) end
  }

  local fn = levels[level] or levels.info
  fn(string.format(message, ...))
end

--- Addon weapons are often added with uppercase keys ("WEAPON_M4") or string names/models.
--- Inventories are matched in lowercase and GetSelectedPedWeapon returns hashes, so normalize once.
function NormalizeWeaponConfig()
  local weapons = {}
  for key, weapon in pairs(Config.Weapons) do
    local name = weapon.name or key
    weapons[key:lower()] = {
      model = type(weapon.model) == "string" and GetHashKey(weapon.model) or weapon.model,
      name = type(name) == "string" and GetHashKey(name) or name,
    }
  end
  Config.Weapons = weapons
end

--- Loads the configured locale. "auto" follows the replicated ox:locale convar (setr ox:locale "sv").
--- Region codes such as "pt-BR" fall back to "pt", and anything without a locale file to "en".
function InitLocale()
  local key = Config.Locale
  if type(key) ~= "string" or key == "auto" then
    key = GetConvar("ox:locale", "en")
  end

  local resource = GetCurrentResourceName()
  local function hasLocale(name)
    return name and LoadResourceFile(resource, ("locales/%s.json"):format(name)) ~= nil
  end

  if not hasLocale(key) then
    local language = key:match("^(%a+)")
    key = hasLocale(language) and language or "en"
  end

  lib.locale(key)
end

-------------------------------------------------------------------------------------------------------------------
-- Environment: framework and inventory
--
-- The server decides, because only the server sees every resource: a client only knows the resources it has
-- mounted already, so a framework ensured after force-sling reads "missing" there. A framework that is installed
-- but not started yet is waited for without a time limit, with a red warning every 10 seconds. The inventory is
-- re-checked whenever an inventory resource starts or stops, so one ensured later is picked up as well.
-- The decision is replicated through GlobalState; clients wait for it and never detect on their own.
-------------------------------------------------------------------------------------------------------------------

local RESOURCE = GetCurrentResourceName()
local IS_SERVER = IsDuplicityVersion()
local ENV_KEY = RESOURCE .. ":environment"

--- Prints to the console regardless of Config.Debug (setup problems must always be visible).
--- @param level "error"|"warn"|"info"
function Log(level, message)
  local color = level == "error" and "^1" or level == "warn" and "^3" or "^2"
  print(("%s[%s] %s^7"):format(color, RESOURCE, tostring(message)))
end

-- qbx_core before qb-core: qbx_core `provide`s qb-core, so GetResourceState('qb-core') is "started" on QBox too
local FRAMEWORKS = {
  { name = "qbx",    resource = "qbx_core" },
  { name = "esx",    resource = "es_extended" },
  { name = "qbcore", resource = "qb-core" },
}

-- qb-inventory last: forks (and some paid inventories) `provide` it, which makes its state "started" for them too
local INVENTORIES = {
  { name = "qs-inventory",     resource = "qs-inventory" },
  { name = "core_inventory",   resource = "core_inventory" },
  { name = "tgiann-inventory", resource = "tgiann-inventory" },
  { name = "ox_inventory",     resource = "ox_inventory" },
  { name = "qb-inventory",     resource = "qb-inventory" },
}

local DEFAULT_RESOURCES = { esx = "es_extended", qbcore = "qb-core", qbx = "qbx_core" }

local environment = {} -- framework, frameworkResource, inventory
local frameworkInits = {}
local frameworkActive = false

local function IsInstalled(resource)
  local state = GetResourceState(resource)
  return state ~= "missing" and state ~= "unknown"
end

--- First running candidate, otherwise nil and the candidates that are installed but not started yet
local function FindRunning(list)
  for _, entry in ipairs(list) do
    if IsResourceStartingOrStarted(entry.resource) then return entry end
  end
  local waiting = {}
  for _, entry in ipairs(list) do
    if IsInstalled(entry.resource) then waiting[#waiting + 1] = entry.resource end
  end
  return nil, waiting
end

--- Resource name of the active framework ("auto" -> the framework's default resource).
--- @param default string|nil
--- @return string|nil
function GetFrameworkResource(default)
  local resource = Config.Framework.resource
  if not resource or resource == "auto" then
    return default or DEFAULT_RESOURCES[Config.Framework.name]
  end
  return resource
end

local function RunFrameworkInit(init)
  local ok, err = pcall(init)
  if not ok then
    Log("error", ("Framework file for '%s' failed: %s"):format(tostring(Config.Framework.name), tostring(err)))
  end
end

--- Framework files (client/custom/frameworks) register their body here. It runs once the framework is known:
--- right away when it already is, otherwise as soon as the server has decided.
--- @param name string "esx" | "qbcore" | "qbx" | "custom"
--- @param init function
function RegisterFramework(name, init)
  if frameworkActive then
    if Config.Framework.name == name then RunFrameworkInit(init) end
    return
  end
  frameworkInits[name] = frameworkInits[name] or {}
  table.insert(frameworkInits[name], init)
end

local function ActivateFramework(name, resource)
  if frameworkActive then return end
  Config.Framework = { name = name, resource = resource or Config.Framework.resource }
  frameworkActive = true

  local inits = frameworkInits[name]
  frameworkInits = {}
  for _, init in ipairs(inits or {}) do RunFrameworkInit(init) end
  Debug("info", "Framework initialized: " .. name)
end

--- True once the framework is known on this side
function IsFrameworkReady()
  return frameworkActive
end

local function Publish()
  if IS_SERVER then GlobalState[ENV_KEY] = environment end
end

local function ResolveInventory()
  local entry = FindRunning(INVENTORIES)
  local inventory = entry and entry.name or "none"
  if inventory == environment.inventory then return end
  environment.inventory = inventory
  Config.Inventory = inventory
  Debug("info", "Inventory initialized: " .. inventory)
  Publish()
end

local function InitServer()
  local autoInventory = Config.Inventory == "auto"
  environment.inventory = not autoInventory and Config.Inventory or nil

  if Config.Framework.name ~= "auto" then
    environment.framework = Config.Framework.name
    environment.frameworkResource = Config.Framework.resource
    ActivateFramework(Config.Framework.name, Config.Framework.resource)
  end

  if autoInventory then
    ResolveInventory()
    -- An inventory ensured after force-sling (or restarted) replaces the earlier decision
    local function onInventoryChange(resource)
      for _, entry in ipairs(INVENTORIES) do
        if entry.resource == resource then
          -- the stopping resource still reports "stopping"/"started" inside its own stop event
          SetTimeout(0, ResolveInventory)
          return
        end
      end
    end
    AddEventHandler("onServerResourceStart", onInventoryChange)
    AddEventHandler("onServerResourceStop", onInventoryChange)
  end

  -- Also replaces a decision a previous run of this resource left in GlobalState
  Publish()
  if environment.framework then return end

  local function resolved(entry)
    if entry then
      environment.framework, environment.frameworkResource = entry.name, entry.resource
    else
      environment.framework = "custom"
      Log("warn", "No supported framework (qbx_core, es_extended, qb-core) is installed, using \"custom\". " ..
        "Set Config.Framework.name and edit client/custom/frameworks/custom.lua for your framework.")
    end
    ActivateFramework(environment.framework, environment.frameworkResource)
    Publish()
  end

  local entry, waiting = FindRunning(FRAMEWORKS)
  if entry or #waiting == 0 then return resolved(entry or false) end

  CreateThread(function()
    local nextWarning = GetGameTimer() + 10000
    while true do
      Wait(250)
      entry, waiting = FindRunning(FRAMEWORKS)
      if entry or #waiting == 0 then return resolved(entry or false) end
      if GetGameTimer() >= nextWarning then
        Log("error", ("Waiting for the framework (%s) to start. Ensure it before %s in server.cfg, remove it if you " ..
          "don't use it, or set Config.Framework.name."):format(table.concat(waiting, ", "), RESOURCE))
        nextWarning = GetGameTimer() + 10000
      end
    end
  end)
end

local function InitClient()
  local function Apply(env)
    if type(env) ~= "table" then return end
    if type(env.inventory) == "string" and env.inventory ~= environment.inventory then
      environment.inventory = env.inventory
      Config.Inventory = env.inventory
      Debug("info", "Inventory initialized: " .. env.inventory)
    end
    if type(env.framework) == "string" and not frameworkActive then
      environment.framework, environment.frameworkResource = env.framework, env.frameworkResource
      ActivateFramework(env.framework, env.frameworkResource)
    end
  end

  -- The inventory can change later (ensured after force-sling), so keep listening
  AddStateBagChangeHandler(ENV_KEY, "global", function(_, _, value)
    Apply(value)
  end)

  -- Usually the server decided long before the client joined
  Apply(GlobalState[ENV_KEY])
  if frameworkActive and environment.inventory then return end

  CreateThread(function()
    local nextWarning = GetGameTimer() + 15000
    while not (frameworkActive and environment.inventory) do
      Wait(500)
      Apply(GlobalState[ENV_KEY])
      if not frameworkActive and GetGameTimer() >= nextWarning then
        Log("warn", "Still waiting for the server to detect the framework (see the server console).")
        nextWarning = GetGameTimer() + 15000
      end
    end
  end)
end

--- Called once per side, after the config files.
function InitEnvironment()
  local ok, err = pcall(IS_SERVER and InitServer or InitClient)
  if not ok then Log("error", "Environment initialization failed: " .. tostring(err)) end
end

--- Calls getter() until it returns a value. If the framework isn't running on this side yet, waits for it without
--- a time limit and warns every 10 seconds. Runs again when the framework restarts (cached objects go stale).
--- @param resource string
--- @param getter fun(): any
--- @param onLoaded fun(obj: any)
function LoadFrameworkObject(resource, getter, onLoaded)
  local loading = false
  local function load()
    if loading then return end
    loading = true
    CreateThread(function()
      local nextWarning = GetGameTimer() + 10000
      while true do
        if GetResourceState(resource) == "started" then
          local ok, obj = pcall(getter)
          if ok and obj then
            onLoaded(obj)
            loading = false
            return
          end
        end
        if GetGameTimer() >= nextWarning then
          Log("warn", ("Still waiting for %s to start. Ensure it before %s in server.cfg."):format(resource, RESOURCE))
          nextWarning = GetGameTimer() + 10000
        end
        Wait(250)
      end
    end)
  end

  load()
  AddEventHandler(IS_SERVER and "onServerResourceStart" or "onClientResourceStart", function(started)
    if started == resource then load() end
  end)
end

-- Safe default until a framework file is active (client/custom/frameworks replaces it)
if not IS_SERVER then
  function IsPlayerLoaded() return false end
end
