-- UI

local function TryApplyComponent(x, y, component)
	local id = Dungeon.floor:ID(x, y)
	local entities = Dungeon.entities[id] or {}
	if #entities > 0 then
		for _, e in pairs(entities) do
			e:Set(component)
		end
	end
end

DebugWordsLibrary = {
	{
		name = "calm",
		callback = function (x, y)
			TryApplyComponent(x, y, Calm { level = 1, chance = 8 })
		end
	},

	{
		name = "yearn",
		callback = function (x, y)
			TryApplyComponent(x, y, Yearn { level = 1, chances = 8 })
		end
	},

	{
		name = "heal",
		callback = function (x, y)
			TryApplyComponent(x, y, Heal { level = 1 })
		end
	},

	{
		name = "endure",
		callback = function (x, y)
			TryApplyComponent(x, y, Endure { level = 1, turns = 8 })
		end
	},

	{
		name = "luck",
		callback = function (x, y)
			TryApplyComponent(x, y, Luck { level = 1, chance = 5, multiplier = 2 })
		end
	},

	{
		name = "light",
		callback = function (x, y)
			TryApplyComponent(x, y, Light { level = 1, chance = 8, bonusRadius = 5 })
		end
	},

	{
		name = "brake",
		callback = function (x, y)
			TryApplyComponent(x, y, Break { level = 1, chance = 8 })
		end
	},
}