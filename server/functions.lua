Sling = {}

--- Initializes the main functionality of Sling.
function Sling:InitMain()
  lib.print.info("Initializing main")
  Sling:Debug("info", "Initializing main")

  -- Load server callbacks
  Sling:LoadServerCallbacks()

  lib.print.info("Main initialized")
  Sling:Debug("info", "Main initialized")
end

--- Debug function to print messages based on the type.
---@param type string The type of the debug message (error, warn, info, verbose, debug).
---@param message string The debug message to print.
function Sling:Debug(type, message)
  if not Config.Debug then return end;
  lib.print[type](message);
end
