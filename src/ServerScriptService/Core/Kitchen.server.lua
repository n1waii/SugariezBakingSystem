-- // Services \\ --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- // Variables \\ --
local SharedModules = ReplicatedStorage.Modules
local Remotes = ReplicatedStorage.Remotes
local KitchenRemotes = Remotes.Kitchen
local ServerAssets = ServerStorage.Assets

local Recipes = require(SharedModules.Recipes)
local TimeoutWait = require(SharedModules.TimeoutWait)
local ToolFunctions = require(SharedModules.ToolFunctions)

-- // Main \\ --
KitchenRemotes.GiveFlour.OnServerEvent:Connect(function(Player)
	local Tools = ToolFunctions.GetTools(Player)
	if not Tools or ToolFunctions.FindToolFromName(Tools, "Flour") == nil then
		ServerAssets.Kitchen.Ingredients["Flour"]:Clone().Parent = Player.Backpack
	end
end)

KitchenRemotes.GiveEggs.OnServerEvent:Connect(function(Player)
	local Tools = ToolFunctions.GetTools(Player)
	if not Tools or ToolFunctions.FindToolFromName(Tools, "Egg") == nil then
		ServerAssets.Kitchen.Ingredients["Egg"]:Clone().Parent = Player.Backpack
	end
end)

KitchenRemotes.GiveVanilla.OnServerEvent:Connect(function(Player)
	local Tools = ToolFunctions.GetTools(Player)
	if not Tools or ToolFunctions.FindToolFromName(Tools, "Vanilla Extract") == nil then
		ServerAssets.Kitchen.Ingredients["Vanilla Extract"]:Clone().Parent = Player.Backpack
	end
end)

KitchenRemotes.Mix.OnServerEvent:Connect(function(Player, selectable, food)
	local Tools = ToolFunctions.GetTools(Player)
	if Tools then
		if not selectable.Occupied.Value and not Player.KitchenFolder.inAction.Value then
			local Content = Recipes["Mixing Bowl"][food]
			if food ~= nil then
				selectable.Occupied.Value = true
				Player.KitchenFolder.inAction.Value = true
				Player.Character.Humanoid.WalkSpeed = 0
				Player.Character.Humanoid.JumpPower = 0
				
				local IngredientTools = ToolFunctions.GetToolsFromArray(Player, Content.Ingredients)
				ToolFunctions.DestroyTools(IngredientTools)
				
				KitchenRemotes.Mix:FireAllClients(
					Player,
					selectable.Parent, 
					food,
					Content
				)
				wait(Content.Time)
				if Player ~= nil then
					local FoodTool = ServerAssets.Kitchen.Ingredients[food]:Clone()
					FoodTool.Parent = Player.Backpack
					Player.KitchenFolder.inAction.Value = false
					Player.Character.Humanoid.WalkSpeed = 16
					Player.Character.Humanoid.JumpPower = 50
				end
				selectable.Occupied.Value = false
			end
		end
	end
end)

--
--KitchenRemotes.Cook.OnServerEvent:Connect(function(Player)
--	local function GetUnoccupiedStove()
--		for _,v in pairs(workspace.Kitchen.Stove.Stoves:GetChildren()) do
--			if v.Name == "Stove" then
--				if v.Occupied.Value == false then
--					return v
--				end
--			end
--		end
--		return nil
--	end
--	
--	local function WaitForIngrediant(pan, ingrediantNeeded, t)
--		KitchenRemotes.IngrediantNeeded:FireClient(Player, pan, ingrediantNeeded)
--				
--		local AddIngrediantConnection; 
--		local Done = false
--		
--		AddIngrediantConnection = KitchenRemotes.AddIngrediant.OnServerEvent:Connect(function(vPlayer)
--			if Player == vPlayer then
--				local Ingrediant = ToolFunctions.GetHoldingTool(vPlayer)
--				if Ingrediant and Ingrediant.Name == ingrediantNeeded then	
--					Ingrediant:Destroy()
--					Done = true
--				end
--			end
--		end)
--		
--		local s = tick()
--		for i = 0, t, (1/60) do
--			if Done then 
--				AddIngrediantConnection:Disconnect()
--				break 
--			end
--			
--			if (tick()-s) >= t then
--				AddIngrediantConnection:Disconnect()
--				return false
--			end
--			
--			if (tick()-s) >= (t/1.5) then
--				local Fire = Instance.new("Fire")
--				Fire.Size = 2
--				Fire.Heat = 1
--				Fire.Color = Color3.fromRGB(179, 111, 28)
--				Fire.SecondaryColor = Color3.fromRGB(139, 92, 37)
--				Fire.Parent = pan.PrimaryPart
--			end
--			
--			RunService.Heartbeat:Wait()
--		end
--		
--		if AddIngrediantConnection.Connected then
--			return false
--		else
--			return true
--		end
--	end
--								
--	local Tool = ToolFunctions.GetHoldingTool(Player)
--	if Tool then
--		local FoodContent = Recipes[Tool.Name]
--		if FoodContent and FoodContent.Stage == "Stove" then
--			local Pan = ServerAssets.Kitchen.Pan:Clone()
--			local Stove = GetUnoccupiedStove()
--			if Stove then
--				Stove.Occupied.Value = true
--				if GetUnoccupiedStove() == nil then
--					workspace.Kitchen.Stove.Stoves.Selectable.Occupied.Value = true
--				end
--				Tool:Destroy()
--				local Rot = CFrame.Angles(0, math.rad(90), 0)
--				local Rot2 = Stove.PosPart.Rot.Value
--				local YOffset = CFrame.new(0, 0.2, 0)
--				Pan:SetPrimaryPartCFrame(Stove.PosPart.CFrame*YOffset*Rot*Rot2)
--				Pan.Parent = workspace
--				Pan.PrimaryPart.Smoke.Enabled = true
--				local Completed = nil
--				if FoodContent["IngrediantsNeeded"] then
--					for i = 1, #FoodContent.IngrediantsNeeded+1 do
--						if Completed ~= nil then break end
--						local DividedTime = math.floor(FoodContent.Time/(#FoodContent.IngrediantsNeeded+1))
--						if i == #FoodContent.IngrediantsNeeded + 1 then
--							KitchenRemotes.StartProgress:FireClient(Player, Pan, FoodContent.Action, DividedTime)
--							wait(DividedTime)
--							Completed = true
--							continue
--						end
--						local IngrediantNeeded = FoodContent.IngrediantsNeeded[i]
--						KitchenRemotes.StartProgress:FireClient(Player, Pan, FoodContent.Action, DividedTime)
--						wait(DividedTime)
--						Pan.IngrediantNeeded.Value = IngrediantNeeded
--						local IngrediantAdded = WaitForIngrediant(Pan, IngrediantNeeded, FoodContent.TimeOut)
--						if IngrediantAdded == true then
--							local Fire = Pan.PrimaryPart:FindFirstChild("Fire")
--							if Fire then
--								Fire:Destroy()
--							end
--							continue
--						else
--							Completed = false
--						end
--					end
--				else
--					wait(FoodContent.Time)
--				end
--				Pan:Destroy()
--				if Player ~= nil then
--					local Food = ServerAssets.Kitchen.Ingrediants[FoodContent["NextTool"]]:Clone()
--					if not Completed then
--						Food.Name = "Burnt " .. Food.Name
--						Food.Handle.UsePartColor = true
--						Food.Handle.BrickColor = BrickColor.new("Really black")
--					end
--					Food.Parent = Player.Backpack
--				end
--				Stove.Occupied.Value = false
--				if GetUnoccupiedStove() ~= nil then
--					workspace.Kitchen.Stove.Stoves.Selectable.Occupied.Value = false
--				end
--			else
--				workspace.Kitchen.Stove.Stoves.Selectable.Occupied.Value = true
--			end
--		end
--	end
--end)