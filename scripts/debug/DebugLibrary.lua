-- UI

local DebugSpawnLibrary = {
	{
		name = "goblin", 
		callback = function(x, y)
			World:Entity(
				Creature(),
				AIMoveTowardsPlayer{ distance = 0, chance = 90 },
				Health { current = 3, maximum = 3 },
				BumpAttack { damage = 1 },
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
	},

	{
		name = "telepathic",
		callback = function (x, y)
			World:Entity(
				Item { id = "stone"},
				Position{ x = x, y = y },
				Glyph{ name = "%" },
				InflictStatus { component = function() return Telepathic { duration = 5, turnsLeft = 5 } end }
			)
		end
	},

	{
		name = "healing",
		callback = function (x, y)
			World:Entity(
				Item { id = "stone"},
				Position{ x = x, y = y },
				Glyph{ name = "H" },
				InflictStatus { component = function() return Heal { level = 1 } end }
			)
		end
	}
}

DebugSpawnUI = World:Entity(
	Contents{items = DebugSpawnLibrary},
	Selection(1)
)