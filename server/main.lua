-- Initialize the framework
Sling:InitFramework()

-- Initialize the inventory
Sling:LoadInventory()

-- Create a new thread to initialize the main functionality
CreateThread(function()
  Sling:InitMain()
end)
