-- // Services \\ --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- // Variables \\ --
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local KitchenFolder = Player:WaitForChild("KitchenFolder")

local ClientModules = script.Parent.Modules
local SharedModules = ReplicatedStorage.Modules
local Remotes = ReplicatedStorage.Remotes
local KitchenRemotes = Remotes.Kitchen
local Assets = ReplicatedStorage.Assets
local KitchenAssets = Assets.Kitchen
local UserInterface = Assets.UserInterface

local ToolFunctions = require(SharedModules.ToolFunctions)
local Sound = require(ClientModules.Sound)
local Recipes = require(SharedModules.Recipes)

-- // Functions \\ --
local function StartProgress(part, action, t) -- // Progression UI for what action you are doing.
	local OldUI = part:FindFirstChild("ProgressUI")
	if OldUI then 
		OldUI:Destroy()
	end
	
	local ProgressUI = KitchenAssets.ProgressUI:Clone()
	ProgressUI.Action.Text = action .. "..."
	ProgressUI.Parent = part
	
	local ProgressTweenInfo = TweenInfo.new(t, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local ProgressTween = TweenService:Create(ProgressUI.Main.Tween, ProgressTweenInfo, {
		Size = UDim2.new(1, 0, 1, 0)
	})
	ProgressTween:Play()
	ProgressTween.Completed:Wait()
	ProgressTween:Destroy()
	ProgressUI:Destroy()
end

local function StarEffect(model)
	local StarTween = TweenService:Create(
		FoodModel.PrimaryPart.BillboardGui.Star, 
		TweenInfo.new(2, Enum.EasingStyle.Linear), 
		{
			Rotation = 360
		}
	):Play()
end

-- // Client Kitchen Events \\ --
KitchenRemotes.Counter.OnClientEvent:Connect(function(player, model, toolModel)
	TweenService:Create(toolModel.PrimaryPart, TweenInfo.new(0.5), {
		CFrame = model.Placement.CFrame
	}):Play()
end)

KitchenRemotes.Mix.OnClientEvent:Connect(function(player, model, food, content) -- // Mixing visuals
	local success, err = pcall(function()
		local DividedTime = (content.Time/2.5) / #content.Ingredients
		local IngredientTweenInfo = TweenInfo.new(DividedTime/2, Enum.EasingStyle.Linear)
		
		StarterGui:SetCore("ResetButtonCallback", false)

		-- // Rotate Top In/Out \\ --
		local TopTweenOut = TweenService:Create(model.Top, TweenInfo.new(1), {
			CFrame = model.Top.CFrame * CFrame.Angles(0, 0, math.rad(90))
		})

		local TopTweenIn = TweenService:Create(model.Top, TweenInfo.new(1), {
			CFrame = model.Top.CFrame * CFrame.Angles(0, 0, 0)
		})

		-- // Whisk Spinning \\ --
		local WhiskSpin = TweenService:Create(
			model.Whisk, 
			TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false), 
			{
				CFrame = model.Whisk.CFrame * CFrame.Angles(0, math.rad(90), 0)
			}
		)

		TopTweenOut:Play()
		TopTweenOut.Completed:Wait()

		coroutine.wrap(function()
			StartProgress(model.Top, "Mixing", content.Time-1)
		end)()
		
		local function TweenIngredient(ingredientName)
			local Ingredient = Assets.Ingredients[ingredientName]:Clone()
			Ingredient.Parent = workspace

			Ingredient:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame)
			
			local Tween1 = TweenService:Create(Ingredient.PrimaryPart, IngredientTweenInfo, {
				CFrame = model.IngredientTween.CFrame * CFrame.new(0, 2, 0) 
			})

			local Tween2 = TweenService:Create(Ingredient.PrimaryPart, IngredientTweenInfo, {
				CFrame = model.IngredientTween.CFrame 
			})

			Tween1:Play()
			Tween1.Completed:Wait()
			Tween2:Play()
			Tween2.Completed:Wait()
			for _,d in pairs(Ingredient:GetDescendants()) do -- // Fade effect
				if d:IsA("BasePart") then
					TweenService:Create(d, TweenInfo.new(0.5), {
						Transparency = 1
					}):Play()
				end
			end
			wait(0.5)
			Ingredient:Destroy()
		end
		
		for _,toolName in pairs(content.Ingredients) do
			coroutine.wrap(function()
				TweenIngredient(toolName)
			end)()
			wait(DividedTime)
		end

		TopTweenIn:Play()
		TopTweenIn.Completed:Wait()
		model.Whisk.Weld.Enabled = false
		WhiskSpin:Play()
		Sound:Add(365965609, 0.5, 3)
		wait(3)
		WhiskSpin:Cancel()
		model.Whisk.Weld.Enabled = true
		StarterGui:SetCore("ResetButtonCallback", true)
	end)

	if not success then
		warn(err)
	end
end)

