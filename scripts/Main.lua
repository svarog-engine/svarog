DoMeasurements = false 

IncludeGameplay "DungeonMaker"
IncludeGameplay "BumpMechanics"
IncludeGameplay "ItemLibrary"
IncludeGameplay "algorithms//RecursiveShadowcast"

LoadPlayerSystem "InputActions"

LoadEnviroSystem "DoorMechanics"
LoadEnviroSystem "FriendlySwapBehaviour"
LoadEnviroSystem "PickUpMechanics"
LoadEnviroSystem "PassabilityUpdate"
LoadEnviroSystem "AIBehaviours"
LoadEnviroSystem "TurnOrder"
LoadEnviroSystem "UpdateDistances"
LoadEnviroSystem "ShadowCastMechanics"

LoadRenderSystem "DungeonRender"
LoadRenderSystem "FadeOutRender"
LoadRenderSystem "PlayerLightRender"
LoadRenderSystem "DebugDistancesRender"
LoadRenderSystem "TopLevelRender"
LoadRenderSystem "LogRender"
LoadRenderSystem "InventoryRender"

IncludeGameplay "procgen\\PCGDungeon"

World:Entity(
	Creature(),
	Friendly(),
	AIMoveTowardsPlayer{ distance = 0, chance = 50 },
	KeepDistanceFromPlayer{ distance = 3, chance = 50 },
	Position{ x = 14, y = 7 },
	Glyph{ name = "pet" }
)

World:Entity(
	Creature(),
	AIMoveTowardsPlayer{ distance = 0, chance = 90 },
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
	Item{id = "key"},
	Position{x = 12, y = 10},
	Glyph{name = "key"}
)

World:Entity(MakeDungeonRequest)
Diary.Write("Welcome to Svarog")
