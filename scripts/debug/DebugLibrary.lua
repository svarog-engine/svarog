-- UI

DebugSpawnLibrary = {
	{
		name = "weak goblin", 
		callback = function(x, y)
			World:Entity(
				Creature(),
				AIMoveTowardsPlayer{ distance = 0, chance = 90 },
				Health(Range(3)),
				BumpAttack { damage = 2 },
				Position{ x = x, y = y },
				Glyph{ name = "goblin" }
			)
		end
	},

	{
		name = "strong goblin", 
		callback = function(x, y)
			World:Entity(
				Creature(),
				AIMoveTowardsPlayer{ distance = 0, chance = 90 },
				Health(Range(3)),
				BumpAttack { damage = 12 },
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
				InflictStatus { component = function() return Telepathic(Range(5)) end }
			)
		end
	},
}

DebugSpawnUI = World:Entity(
	Contents{items = DebugSpawnLibrary},
	Selection(1)
)