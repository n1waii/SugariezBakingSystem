local Module = {}

function Module.GetHoldingTool(Player)
	return Player.Character:FindFirstChildOfClass("Tool")	
end

function Module.GetTools(Player)
	local Tools = {}
	for _,v in pairs(Player.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			table.insert(Tools, v)
		end
	end
	
	local HoldingTool = Module.GetHoldingTool(Player)
	if HoldingTool then
		table.insert(Tools, HoldingTool)
	end
	
	return Tools
end

function Module.GetToolsFromArray(player, array)
	local Tools = Module.GetTools(player)
	local ToolsWanted = {}

	if Tools then
		for i,tool in pairs(Tools) do
			if table.find(array, tool.Name) then
				table.insert(ToolsWanted, tool)
			end
		end
	end

	return ToolsWanted
end

function Module.DestroyTools(tools)
	for _,tool in pairs(tools) do
		tool:Destroy()
	end
end

function Module.FindToolFromName(tools, name)
	if #tools == 0 then return nil end
	
	for _,tool in pairs(tools) do
		if tool.Name == name then
			return tool
		end
	end
	
	return nil
end

return Module