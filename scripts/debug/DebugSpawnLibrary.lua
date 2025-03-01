DebugSpawnLibrary = {
	goblin = function(x, y)
		World:Entity(
			Creature(),
			AIMoveTowardsPlayer{ distance = 0, chance = 90 },
			Position{ x = x, y = y },
			Glyph{ name = "goblin" }
		)
    end,

	treasure = function(x, y)
		World:Entity(
			Item{id = "treasure"},
			Position{ x = x, y = y },
			Glyph{ name = "treasure" }
		)
    end,
}