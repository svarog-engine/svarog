-- UI

local function TryApplyComponent(x, y, component, name)
	local id = Dungeon.floor:ID(x, y)
	local entities = Dungeon.entities[id] or {}
	if #entities > 0 then
		for _, e in pairs(entities) do
			if e[Boons] ~= nil then
				table.insert(e[Boons].value, name)
			end
			e:Set(component)
		end
	end
end

DebugWordsLibrary = {
	{
		name = "calm",
		callback = function (x, y)
			TryApplyComponent(x, y, Calm { level = 1, chance = 8 }, "Calm")
		end
	},

	{
		name = "open",
		callback = function (x, y)
			TryApplyComponent(x, y, Open { level = 1, chances = 8 }, "Open")
		end
	},

	{
		name = "heal",
		callback = function (x, y)
			TryApplyComponent(x, y, Heal { level = 1 }, "Heal")
		end
	},

	{
		name = "endure",
		callback = function (x, y)
			TryApplyComponent(x, y, Endure { level = 1, turns = 8 }, "Endure")
		end
	},

	{
		name = "luck",
		callback = function (x, y)
			TryApplyComponent(x, y, Luck { level = 1, chance = 5, multiplier = 2 }, "Luck")
		end
	},

	{
		name = "darken",
		callback = function (x, y)
			TryApplyComponent(x, y, Darken { level = 1 ,chance = 5 }, "Darken")
		end
	},

	{
		name = "light",
		callback = function (x, y)
			TryApplyComponent(x, y, Light { level = 1, chance = 8 }, "Light")
		end
	},

	{
		name = "break",
		callback = function (x, y)
			TryApplyComponent(x, y, Break { level = 1, chance = 8 }, "Break")
		end
	},

	{
		name = "flow",
		callback = function (x, y)
			TryApplyComponent(x, y, Flow { level = 1, chance = 8 }, "Flow")
		end
	},
}