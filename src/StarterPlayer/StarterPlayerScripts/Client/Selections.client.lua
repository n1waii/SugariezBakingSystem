--[[
	Notes:
	- None
--]]

-- // Services \\ --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- // Variables \\ --
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local InteractionKey = PlayerGui:WaitForChild("InteractionKey")

local Mouse = Player:GetMouse()

local KitchenFolder = Player:WaitForChild("KitchenFolder")

local ClientModules = script.Parent.Modules
local SharedModules = ReplicatedStorage.Modules

local Remotes = ReplicatedStorage.Remotes
local KitchenRemotes = Remotes.Kitchen
local Bindables = ReplicatedStorage.Bindables
local SelectionBindables = Bindables.Selections

local Assets = ReplicatedStorage.Assets
local KitchenAssets = Assets.Kitchen
local UserInterface = Assets.UserInterface

local Selection = require(ClientModules.Selection)
local ToolFunctions = require(SharedModules.ToolFunctions)
local Sound = require(ClientModules.Sound)
local Recipes = require(SharedModules.Recipes)

local Selectables = {}

local InRange = false
local ViewingOptions = false
local LastSelectable = nil

local ButtonDownEffect = false
local TweeningInteractive = false

local RANGE = 7
local KEY = Enum.KeyCode.E

-- // Functions \\ --
local function GetClosestSelectable() -- // Get array of selectables in range 
	local InRange = {}

	for _,v in pairs(Selectables) do
		if v.Selectable.Occupied.Value then continue end
		local mag = (v.PrimaryPart.Position-Player.Character.HumanoidRootPart.Position).Magnitude
		if (mag <= RANGE) and not inAction and not KitchenFolder.inAction.Value then
			table.insert(InRange, {Model = v, Mag = mag})			
		end
	end

	if #InRange > 0 then
		table.sort(InRange, function(a, b)
			return a.Mag < b.Mag
		end)
		return InRange[1].Model
	end

	return nil
end

local function SetupSelectables() --// Sorts all selectables into a table
	for _,v in pairs(workspace:GetDescendants()) do
		--if v:IsA("Model") then
			if v:FindFirstChild("Selectable") then
				table.insert(Selectables, v)
			end
		--end
	end
end

local function CloseInteractive()
	InRange = false
	LastSelectable = nil
	local t = TweenService:Create(
		InteractionKey.Main.Interactive.UIScale, 
		TweenInfo.new(0.1, Enum.EasingStyle.Linear),
		{
			Scale = 0
		}
	)
	TweeningInteractive = true
	t:Play()
	t.Completed:Connect(function() 
		InteractionKey.Adornee = nil
		TweeningInteractive = false
	end)
end

local function CreateOptions(options)
	if ViewingOptions then return end
	ViewingOptions = true
	InteractionKey.Main.Options.UIScale.Scale = 0
	InteractionKey.Main.Interactive.UIScale.Scale = 0
	
	for i, option in ipairs(options) do
		local Option = InteractionKey.OptionTemplate:Clone()
		Option.Tween.Text = " (" .. i .. ") " .. option.Name .. " "
		Option.Position = InteractionKey.Main.Options[i].Position
		Option.Visible = true
		Option.Parent = InteractionKey.Main.Options
		Option.MouseButton1Click:Connect(option.Callback)
	end

	TweenService:Create(
		InteractionKey.Main.Options.UIScale, 
		TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Scale = 1
		}
	):Play()
end

local function DestroyOptions()
	local t = TweenService:Create(
		InteractionKey.Main.Options.UIScale, 
		TweenInfo.new(0.1, Enum.EasingStyle.Linear),
		{
			Scale = 0
		}
	)
	t:Play()
	t.Completed:Connect(function()
		ViewingOptions = false
		LastSelectable = nil
		for _,option in pairs(InteractionKey.Main.Options:GetChildren()) do
			if option.Name == "OptionTemplate" then
				option:Destroy()
			end
		end
	end)
end

-- // Main \\ --
SetupSelectables()

UserInputService.InputBegan:Connect(function(Input, GameProcessed) -- // On Key pressed
	if GameProcessed or TweeningInteractive then return end
	if Input.KeyCode == KEY then
		local closestSelectable = GetClosestSelectable()
		if closestSelectable then
			local selectable = closestSelectable.Selectable
			if not selectable.Occupied.Value then
				SelectionBindables[selectable.Bindable.Value]:Fire(selectable)
			end

			-- // Button Down Effect \\ --
			if not ButtonDownEffect then
				ButtonDownEffect = true
				local ButtonDownTween = TweenService:Create(
					InteractionKey.Main.Interactive.Tween,
					TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In, 0, true),
					{
						Position = UDim2.fromScale(0, 0.1)
					}
				)
				ButtonDownTween:Play()
				ButtonDownTween.Completed:Connect(function()
					ButtonDownEffect = false
				end)
			end
		end
	end
end)

RunService.RenderStepped:Connect(function() -- // Selectable effect handler
	if not Player.Character then
		return
	end

	local closestSelectable = GetClosestSelectable()
	if closestSelectable then -- // Tween In
		InteractionKey.Adornee = closestSelectable.PrimaryPart
		if not InRange or LastSelectable ~= closestSelectable then
			if ViewingOptions then
				DestroyOptions()
			end
			LastSelectable = closestSelectable
			InRange = true
			Sound:Add(424002310, 1, 1)
			InteractionKey.Main.Interactive.UIScale.Scale = 0
			local t = TweenService:Create(
				InteractionKey.Main.Interactive.UIScale, 
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Scale = 1
				}
			)
			TweeningInteractive = true
			t:Play()
			t.Completed:Connect(function()
				TweeningInteractive = false
			end)
		end
	else -- // Tween Out
		if InRange then		
			DestroyOptions()
			CloseInteractive()
		end
	end
end)

-- // Selection Events \\ --
SelectionBindables.Eggs.Event:Connect(function()
	local Tools = ToolFunctions.GetTools(Player)
	if not Tools or ToolFunctions.FindToolFromName(Tools, "Eggs") == nil then
		KitchenRemotes.GiveEggs:FireServer()
	end
end)

SelectionBindables.Flour.Event:Connect(function()
	local Tools = ToolFunctions.GetTools(Player)
	if not Tools or ToolFunctions.FindToolFromName(Tools, "Flour") == nil then
		KitchenRemotes.GiveFlour:FireServer()
	end
end)

SelectionBindables.Vanilla.Event:Connect(function()
	local Tools = ToolFunctions.GetTools(Player)
	if not Tools or ToolFunctions.FindToolFromName(Tools, "Vanilla Extract") == nil then
		KitchenRemotes.GiveVanilla:FireServer()
	end
end)

SelectionBindables.OvenOptions.Event:Connect(function()
	local Options = {
		{
			Name = "Stove", 
			Callback = function()
				DestroyOptions()
			end
		},
		{
			Name = "Oven", 
			Callback = function()
				DestroyOptions()
			end
		}
	}

	CreateOptions(Options)
end)

SelectionBindables.Mix.Event:Connect(function(Selected)
	local Tools = ToolFunctions.GetTools(Player)

	if Tools then
		local AvailableRecipes = Recipes.FindRecipes("Mixing Bowl", Tools)
		if AvailableRecipes ~= nil then -- // Makes sure they have the tools to mix something 
			local Options = {}

			for foodName, content in pairs(AvailableRecipes) do
				table.insert(Options, {Name = foodName, Callback = function()
					KitchenRemotes.Mix:FireServer(Selected, foodName)
				end})
			end

			CreateOptions(Options)	
		end
	end
end)