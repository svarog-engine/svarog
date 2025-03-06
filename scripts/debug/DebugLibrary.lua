-- UI

DebugSpawnLibrary = {
	{
		name = "weak goblin", 
		callback = function(x, y)
			AddEntityToDungeon(x, y, World:Entity(
				Creature{ goals = {}, actions = 0, timestamp = 0 },
				AIMoveTowardsPlayer{ distance = 0, chance = 9 },
				Health(Range(3)),
				BumpAttack { damage = 2 },
				Darken {level = 1, chance = 8 },
				Position{ x = x, y = y },
				Glyph{ name = "goblin" },
				Name("goblin")
			))
		end
	},

	{
		name = "strong goblin", 
		callback = function(x, y)
			AddEntityToDungeon(x, y, World:Entity(
				Creature{ goals = {}, actions = 0, timestamp = 0 },
				AIMoveTowardsPlayer{ distance = 0, chance = 9 },
				Health(Range(3)),
				BumpAttack { damage = 12 },
				Position{ x = x, y = y },
				Glyph{ name = "goblin" },
				Name("gob")
			))
		end
	},

	{ 
		name = "treasure",
		callback = function(x, y)
			AddEntityToDungeon(x, y, World:Entity(
				Item{id = "treasure"},
				Position{ x = x, y = y },
				Glyph{ name = "treasure" },
				Name("treasure")
			))
		end
	},

	{ 
		name = "crate",
		callback = function(x, y)
			AddEntityToDungeon(x, y, World:Entity(
				Item{id = "crate"},
				Position{ x = x, y = y },
				Glyph{ name = "crate" },
				Name("crate"),
				BlockingPassage{}
			))
		end
	},

	{
		name = "telepathic",
		callback = function (x, y)
			AddEntityToDungeon(x, y, World:Entity(
				Item { id = "stone"},
				Position{ x = x, y = y },
				Glyph{ name = "%" },
				ProvideStatus { component = function() return Telepathic(Range(5)) end }
			))
		end
	},
}

DebugSpawnUI = World:Entity(
	Contents{items = DebugSpawnLibrary},
	Selection(1)
)