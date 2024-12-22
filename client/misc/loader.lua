function Sling:InitFramework()
  Sling:Debug("info", "Initializing framework")
  if Config.Framework.name == "auto" then
    if GetResourceState("es_extended") ~= "missing" then
      Config.Framework.name = "esx"
      Config.Framework.resource = "es_extended"
      Sling:Debug("info", "Framework set to esx with resource es_extended")
    elseif GetResourceState("qbx_core") ~= "missing" then
      Config.Framework.name = "qbx"
      Config.Framework.resource = "qbx_core"
      Sling:Debug("info", "Framework set to qbx with resource qbx_core")
    elseif GetResourceState("qb-core") ~= "missing" then
      Config.Framework.name = "qbcore"
      Config.Framework.resource = "qb-core"
      Sling:Debug("info", "Framework set to qbcore with resource qb-core")
    else
      Config.Framework.name = "custom"
      Sling:Debug("info", "Framework set to custom")
    end
  end
  Sling:Debug("info", "Framework initialized: " .. Config.Framework.name)
end

function Sling:LoadInventory()
  if Config.Inventory ~= "auto" then return end;

  if GetResourceState("qs-inventory") ~= "missing" then
    Config.Inventory = "qs-inventory"
    Sling:Debug("info", "Inventory set to qs-inventory")
  elseif GetResourceState("qb-inventory") ~= "missing" then
    Config.Inventory = "qb-inventory"
    Sling:Debug("info", "Inventory set to qb-inventory")
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
