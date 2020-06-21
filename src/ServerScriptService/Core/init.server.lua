-- // Services \\ --
local Players = game:GetService("Players")

-- // Variables \\ --

-- // Main \\ --
Players.PlayerAdded:Connect(function(Player)
	local KitchenFolder = Instance.new("Folder")
	KitchenFolder.Name = "KitchenFolder"
	KitchenFolder.Parent = Player
	
	local inAction = Instance.new("BoolValue") 
	inAction.Value = false
	inAction.Name = "inAction"
	inAction.Parent = KitchenFolder
end)