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

local ToolFunctions = require(SharedModules.ToolFunctions)
local Sound = require(ClientModules.Sound)
local Recipes = require(SharedModules.Recipes)

local KeyCodeToIndex = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
}

local Selectables = {}
local Options = {}
local OptionSection = {}
local CurrentSection = nil

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
		if v:IsA("Model") then
			if v:FindFirstChild("Selectable") then
				table.insert(Selectables, v)
			end
		end
	end
end

local function ShiftTable(tbl, inc) -- // Shifts array-like table by increment
	local shiftedTable = {}
	for i,v in pairs(tbl) do
		shiftedTable[i+inc] = v
	end
	return shiftedTable
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

local function CreateOptions(chosenSection, multiplePages)
	if ViewingOptions and chosenSection == CurrentSection then return end
	ViewingOptions = true
	InteractionKey.Main.Options.UIScale.Scale = 0
	InteractionKey.Main.Interactive.UIScale.Scale = 0
	warn(chosenSection)
	local optionSections = nil


	-- // Multiple page handling \\ --
	if multiplePages then 
		local dividedOptions = {}
		local sections = math.ceil(#Options/8)
		print("Max Sections:", sections)
		for section = 1, sections, 1 do
			dividedOptions[section] = {}
			-- // Create Next and Back Button \\ --
			local next = {
				Name = "Next",
				Callback = function()
					print("next")
					CreateOptions(section+1, true)
				end,
			}

			local back = {
				Name = "Back",
				Callback = function()
					print("back")
					CreateOptions(section-1, true)
				end,
			}

			if section < sections then
				table.insert(dividedOptions[section], next) 
			end
			
			if section > 1 then
				table.insert(dividedOptions[section], back) 
			end
			
			local finish = section*8
			local start = finish-7
						
			for optionIndex = start, finish do
				warn(Options[1].Name)
				print("OptionIndex:", optionIndex)
				if #dividedOptions[section] == 8 then 
					print("section filled up")
					break
				elseif not Options[optionIndex] then
					print("option does not exist")
					break 
				end
				print("Option Name:", Options[optionIndex].Name)
				print("Section:", section)
				table.insert(dividedOptions[section], Options[optionIndex]) 
			end
		end

		optionSections = dividedOptions
	else
		optionSections = {[1] = Options}
	end

	OptionSection = optionSections[chosenSection]

	-- // Destroy old options \\ --
	for _,option in pairs(InteractionKey.Main.Options:GetChildren()) do
		if option.Name == "OptionTemplate" then
			option:Destroy()
		end
	end

	-- // Create new options \\ --
	for i, option in pairs(OptionSection) do
		local Option = InteractionKey.OptionTemplate:Clone()
		Option.Tween.Text = " (" .. i .. ") " .. option.Name .. " "
		Option.Position = InteractionKey.Main.Options[i].Position
		Option.Tween.TextColor3 = option.Name == "Next" and Color3.fromRGB(118, 242, 56)
		or option.Name == "Back" and Color3.fromRGB(240, 67, 14)
		or Option.Tween.TextColor3
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
	Options = {}
	OptionSection = {}
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

UserInputService.InputBegan:Connect(function(Input, GameProcessed) -- // On Keys pressed
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

	if #Options > 0  then -- // If there are options
		print("there are options")
		if KeyCodeToIndex[Input.KeyCode] then -- // If it's a number between 1-8
			print("its a number between 1-8")
			local num = KeyCodeToIndex[Input.KeyCode]
			print("Number", num)
			if OptionSection[num] then -- // If there is an option assigned
				print("found it ")
				OptionSection[num].Callback() -- // Run callback function
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
	Options = {
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

	CreateOptions(1, false)
end)

SelectionBindables.Mix.Event:Connect(function(Selected)
	local Tools = ToolFunctions.GetTools(Player)

	if Tools then
		local AvailableRecipes = Recipes.FindRecipes("Mixing Bowl", Tools)
		if AvailableRecipes ~= nil then -- // Makes sure they have the tools to mix something 
			Options = {}

			for foodName, content in pairs(AvailableRecipes) do
				table.insert(Options, {Name = foodName, Callback = function()
					KitchenRemotes.Mix:FireServer(Selected, foodName)
				end})
			end

			CreateOptions(1, #Options>8)	
		end
	end
end)