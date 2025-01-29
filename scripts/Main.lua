
LoadPlayerSystem "InputActions"
LoadPlayerSystem "BumpMechanics"
LoadPlayerSystem "ResolveMove"

LoadEnviroSystem "DungeonMaker"
LoadEnviroSystem "DoorMechanics"
LoadEnviroSystem "FollowBehaviour"
LoadEnviroSystem "ApproachBehaviour"
LoadEnviroSystem "PickUpMechanic"
LoadEnviroSystem "PassabilityUpdate"
LoadEnviroSystem "UpdateDistances"

LoadRenderSystem "DungeonRender"
LoadRenderSystem "FadeOutRender"
LoadRenderSystem "PlayerLightRender"
LoadRenderSystem "DebugDijkstraRender"
LoadRenderSystem "TopLevelRender"
LoadRenderSystem "LogRender"
LoadRenderSystem "InventoryRender"

World:Entity(
	Creature(),
	Friendly(),
	FollowBehaviour{ distance = 2 },
	Position{ x = 14, y = 7 },
	Glyph{ name = "pet" }
)

World:Entity(
	Creature(),
	ApproachBehaviour(),
	Position{ x = 22, y = 22 },
	Glyph{ name = "goblin" }
)

World:Entity(
	Item{id = "treasure"},
	Position{ x = 7, y = 7 },
	Glyph{ name = "treasure" }
)

World:Entity(
	Item{id = "treasure"},
	Position{ x = 10, y = 11 },
	Glyph{ name = "treasure" }
)


PlayerEntity = World:Entity(
	Player(), 
	Position{ x = 10, y = 10 },
	Glyph{ name = "mage" },
	Inventory{ items = {}}
)

World:Entity(
	Item{id = "magic_sword"},
	Position{x = 11, y = 10},
	Glyph{name = "item"}
)

World:Entity(
	Item{id = "magic_wand"},
	Position{x = 12, y = 10},
	Glyph{name = "item"}
)

World:Entity(MakeDungeonRequest)
Diary.Write("Welcome to Svarog")
