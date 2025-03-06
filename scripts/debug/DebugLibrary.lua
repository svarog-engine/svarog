-- UI

DebugSpawnLibrary = {
	{
		name = "weak goblin", 
		callback = function(x, y)
			World:Entity(
				Creature(),
				AIMoveTowardsPlayer{ distance = 0, chance = 9 },
				Health(Range(3)),
				BumpAttack { damage = 2 },
				Darken {level = 1, chance = 8 },
				Position{ x = x, y = y },
				Glyph{ name = "goblin" },
				Name("goblin")
			)
		end
	},

	{
		name = "strong goblin", 
		callback = function(x, y)
			World:Entity(
				Creature(),
				AIMoveTowardsPlayer{ distance = 0, chance = 9 },
				Health(Range(3)),
				BumpAttack { damage = 12 },
				Position{ x = x, y = y },
				Glyph{ name = "goblin" },
				Name("gob")
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
				ProvideStatus { component = function() return Telepathic(Range(5)) end }
			)
		end
	},
}

DebugSpawnUI = World:Entity(
	Contents{items = DebugSpawnLibrary},
	Selection(1)
)