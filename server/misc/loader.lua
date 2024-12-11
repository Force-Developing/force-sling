--- Initializes the framework based on the configuration.
function Sling:InitFramework()
  lib.print.info("Initializing framework")
  Sling:Debug("info", "Initializing framework")
  if Config.Framework.name == "auto" then
    if GetResourceState("es_extended") ~= "missing" then
      Config.Framework.name = "esx"
      Config.Framework.resource = "es_extended"
      Sling:Debug("info", "Framework set to esx with resource es_extended")
    elseif GetResourceState("bablo_base") ~= "missing" then
      Config.Framework.name = "esx"
      Config.Framework.resource = "bablo_base"
      Sling:Debug("info", "Framework set to esx with resource bablo_base")
    elseif GetResourceState("qb-core") ~= "missing" then
      Config.Framework.name = "qbcore"
      Config.Framework.resource = "qb-core"
      Sling:Debug("info", "Framework set to qbcore with resource qb-core")
    else
      Config.Framework.name = "custom"
      Sling:Debug("info", "Framework set to custom")
    end
  end
  lib.print.info("Framework initialized: " .. Config.Framework.name)
  Sling:Debug("info", "Framework initialized: " .. Config.Framework.name)
end

--- Initializes the main functionality of Sling.
function Sling:LoadInventory()
  if Config.Inventory ~= "auto" then return end;

  if GetResourceState("qs_inventory") ~= "missing" then
    Config.Inventory = "qs_inventory"
    Sling:Debug("info", "Inventory set to qs_inventory")
  elseif GetResourceState("qb_inventory") ~= "missing" then
    Config.Inventory = "qb_inventory"
    Sling:Debug("info", "Inventory set to qb_inventory")
  elseif GetResourceState("core_inventory") ~= "missing" then
    Config.Inventory = "core_inventory"
    Sling:Debug("info", "Inventory set to core_inventory")
  elseif GetResourceState("ox_inventory") ~= "missing" then
    Config.Inventory = "ox_inventory"
    Sling:Debug("info", "Inventory set to ox_inventory")
  else
    Config.Inventory = "none"
    Sling:Debug("info", "Inventory set to none")
  end
end
