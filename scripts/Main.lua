
LoadPlayerSystem "InputActions"
LoadPlayerSystem "BumpMechanics"
LoadPlayerSystem "ResolveMove"

LoadEnviroSystem "DungeonMaker"
LoadEnviroSystem "DoorMechanics"
LoadEnviroSystem "FollowBehaviour"
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
	Position{ x = 22, y = 22 },
	Glyph{ name = "goblin" }
)

World:Entity(
	Item(), 
	Position{ x = 7, y = 7 },
	Glyph{ name = "treasure" }
)

World:Entity(
	Item(), 
	Position{ x = 10, y = 11 },
	Glyph{ name = "treasure" }
)

World:Entity(MakeDungeonRequest)
Diary.Write("Welcome to Svarog")

PlayerEntity = World:Entity(
	Player(), 
	Position{ x = 10, y = 10 },
	Glyph{ name = "mage" },
	Inventory{ items = {}}
)