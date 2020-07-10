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

		["Strawberry Cake Mix"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
		["Cake 1"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
		["Cake 2"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
		["Cake 3"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
		["Cake 4"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
		["Cake 5"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
		["Cake 6"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
		["Cake 7"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
		["Cake 8"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
		["Cake 9"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
		["Cake 10"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		},
		["Cake 11"] = {
			Id = 3,
			Ingredients = {
				"Egg",
				"Flour",
				"Vanilla Extract"
			},
			Time = 8,
		}
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
				t += 1
			end
		end
		if t == #content.Ingredients then
			thisRecipes[food] = content
		end
	end

	-- // Checking if dictionary is empty by looping since "#" operator only works on arrays \\ --
	for _ in pairs(thisRecipes) do
		return thisRecipes
	end

	return nil	
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