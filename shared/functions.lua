function IsResourceStartingOrStarted(resource)
  return GetResourceState(resource) == "starting" or GetResourceState(resource) == "started"
end

function InitFramework()
  if not Config.Framework.name == "auto" then return end
  local frameworks = {
    { name = "esx",    resource = "es_extended" },
    { name = "qbx",    resource = "qbx_core" },
    { name = "qbcore", resource = "qb-core" }
  }

  Sling:Debug("info", "Initializing framework")
  for _, framework in ipairs(frameworks) do
    if IsResourceStartingOrStarted(framework.resource) then
      Config.Framework.name = framework.name
      Config.Framework.resource = framework.resource
      return
    end
  end
  Sling:Debug("info", "Framework initialized: " .. Config.Framework.name)
end

function InitInventory()
  if not Config.Inventory == "auto" then return end
  local inventories = {
    { name = "qs-inventory",   resource = "qs-inventory" },
    { name = "core_inventory", resource = "core_inventory" },
    { name = "qb-inventory",   resource = "qb-inventory" },
    { name = "ox_inventory",   resource = "ox_inventory" }
  }

  Sling:Debug("info", "Initializing inventory")
  for _, inventory in ipairs(inventories) do
    if IsResourceStartingOrStarted(inventory.resource) then
      Config.Inventory = inventory.name
      Sling:Debug("info", "Inventory initialized: " .. Config.Inventory)
      return
    end
  end
  Config.Inventory = "none"
  Sling:Debug("info", "Inventory initialized: " .. Config.Inventory)
end
