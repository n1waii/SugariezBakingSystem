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
local function StartProgress(model, action, t) -- // Progression UI for what action you are doing.
	local OldUI = model.PrimaryPart:FindFirstChild("ProgressUI")
	if OldUI then 
		OldUI:Destroy()
	end
	
	local ProgressUI = KitchenAssets.ProgressUI:Clone()
	ProgressUI.Action.Text = action .. "..."
	ProgressUI.Parent = model.PrimaryPart
	
	local ProgressTweenInfo = TweenInfo.new(t, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local ProgressTween = TweenService:Create(ProgressUI.Main.Tween, ProgressTweenInfo, {
		Size = UDim2.new(1, 0, 1, 0)
	})
	ProgressTween:Play()
	ProgressTween.Completed:Wait()
	ProgressTween:Destroy()
	ProgressUI:Destroy()
end

-- // Client Kitchen Events \\ --
KitchenRemotes.Mix.OnClientEvent:Connect(function(player, model, food, content) -- // Mixing visuals
	pcall(function()
		local DividedTime = (content.Time / #content.Ingredients)-1
		local IngredientTweenInfo = TweenInfo.new(DividedTime/2.5, Enum.EasingStyle.Linear)
		
		StarterGui:SetCore("ResetButtonCallback", false)

		spawn(function()
			StartProgress(model, "Mixing", content.Time)
		end)
		
		local function TweenIngredient(ingredientName)
			local Ingredient = Assets.Ingredients[ingredientName]:Clone()
			Ingredient.Parent = workspace

			local x,y,z = Ingredient.PrimaryPart.CFrame:ToEulerAnglesXYZ() -- // Get Rotation
			local rot = CFrame.Angles(x,y,z)

			Ingredient:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame*rot)
			
			local Tween1 = TweenService:Create(Ingredient.PrimaryPart, IngredientTweenInfo, {
				CFrame = model.PrimaryPart.CFrame * CFrame.new(0, 2, 0) * rot
			})	

			local Tween2 = TweenService:Create(Ingredient.PrimaryPart, IngredientTweenInfo, {
				CFrame = model.PrimaryPart.CFrame * rot
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
			spawn(function()
				TweenIngredient(toolName)
			end)
			wait(DividedTime)
		end
	
		wait(3)
		
		local FoodModel = Assets.Ingredients[food]:Clone()
		FoodModel.Parent = workspace
		FoodModel:MoveTo(model.PrimaryPart.Position - Vector3.new(0, 1, 0))
					
		local x,y,z = FoodModel.PrimaryPart.CFrame:ToEulerAnglesXYZ()
		local rot = CFrame.Angles(x,y,z)
	
		local FoodModelTween = TweenService:Create(
			FoodModel.PrimaryPart, 
			TweenInfo.new(1, Enum.EasingStyle.Linear), 
			{
				CFrame = FoodModel.PrimaryPart.CFrame * CFrame.new(0, 3, 0) * rot
			}
		)
		
		local FoodModelTween2 = TweenService:Create(
			FoodModel.PrimaryPart, 
			TweenInfo.new(1, Enum.EasingStyle.Linear), 
			{
				CFrame = player.Character.HumanoidRootPart.CFrame * rot
			}
		)
		
		local StarTween = TweenService:Create(
			FoodModel.PrimaryPart.BillboardGui.Star, 
			TweenInfo.new(2, Enum.EasingStyle.Linear), 
			{
				Rotation = 360
			}
		)
		
		FoodModelTween:Play()
		StarTween:Play()
		FoodModelTween.Completed:Wait()
		wait(1)
		FoodModelTween2:Play()
		FoodModel.PrimaryPart.BillboardGui:Destroy()
		for _,d in pairs(FoodModel:GetDescendants()) do -- // Fade effect
			if d:IsA("BasePart") then
				TweenService:Create(d, TweenInfo.new(1), {
					Transparency = 1
				}):Play()
			end
		end
		wait(1)
		FoodModel:Destroy()
		StarterGui:SetCore("ResetButtonCallback", true)
	end)
end)

