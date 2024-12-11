-- Initialize the framework
Sling:InitFramework()

-- Initialize the inventory
Sling:LoadInventory()

-- Create a new thread to wait until the player is loaded
CreateThread(function()
  -- Wait until the player is fully loaded
  while not IsPlayerLoaded() do
    Wait(100)
  end

  -- Initialize the main functionality of Sling
  Sling:InitMain()
end)
