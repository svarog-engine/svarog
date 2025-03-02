-- UI

local DebugSpawnLibrary = {
	{
		name = "goblin", 
		callback = function(x, y)
			World:Entity(
				Creature(),
				AIMoveTowardsPlayer{ distance = 0, chance = 90 },
				Position{ x = x, y = y },
				Glyph{ name = "goblin" }
			)
		end
	},

	{ 
		name = "treasure",
		callback = function(x, y)
			World:Entity(
				Item{id = "treasure"},
				Position{ x = x, y = y },
				Glyph{ name = "treasure" }
			)
		end
	}
}

DebugSpawnUI = World:Entity(
	Contents{items = DebugSpawnLibrary},
	Selection(1)
)