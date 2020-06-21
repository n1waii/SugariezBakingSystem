local Selection = {
	Selections = {}
}

function Selection.new(model)
	local SelectionBox = Instance.new("SelectionBox")
	SelectionBox.Color3 = Color3.fromRGB(67, 175, 121)
	SelectionBox.SurfaceColor3 = Color3.fromRGB(46, 167, 113)
	SelectionBox.SurfaceTransparency = 0.8
	SelectionBox.LineThickness = 0.1
	SelectionBox.Adornee = model
	SelectionBox.Parent = model
	table.insert(Selection.Selections, SelectionBox)
end

function Selection.clear()
	for _,v in pairs(Selection.Selections) do
		v:Destroy()
	end
end

return Selection