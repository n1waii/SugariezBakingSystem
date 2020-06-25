local Recipes = {
	["Mixing Bowl"] = {
		["Cupcake Mix"] = {
			Id = 1,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
	},
	["Oven"] = {
		["Cupcake"] = {
			Id = 2,
			Ingredients = {
				"Cupcake Mix Liner"
			},
			Time = 5,
		}
	}
}

function Recipes.FindRecipes(machine, tools)
	local thisRecipes = {}
	
	for food, content in pairs(Recipes[machine]) do
		local t = 0
		for _,tool in pairs(tools) do
			if table.find(content.Ingredients, tool.Name) then
				t = t + 1
			end
		end
		if t == #content.Ingredients then
			thisRecipes[food] = content
		end
	end
	
	return thisRecipes ~= nil and thisRecipes or nil
end


function Recipes.FindRecipe(machine, id)	
	for food, content in pairs(Recipes[machine]) do
		if content.Id == id then
			return food, content
		end
	end
	
	return nil
end

return Recipes