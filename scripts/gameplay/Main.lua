
LoadPlayerSystem "InputActions"
LoadPlayerSystem "BumpMechanics"
LoadPlayerSystem "ResolveMove"
LoadPlayerSystem "UpdateDijkstra"

LoadEnviroSystem "DungeonMaker"
LoadEnviroSystem "DoorMechanics"
LoadEnviroSystem "FollowBehaviour"

LoadRenderSystem "DungeonRender"
LoadRenderSystem "FadeOutRender"
LoadRenderSystem "PlayerLightRender"
LoadRenderSystem "DebugDijkstraRender"
LoadRenderSystem "TopLevelRender"
LoadRenderSystem "LogRender"

World:Entity(
	Player, 
	Position{ x = 10, y = 10 },
	Glyph{ name = "mage" }
)

World:Entity(
	Creature, 
	FollowBehaviour{ distance = 3 },
	Position{ x = 14, y = 7 },
	Glyph{ name = "gob1" }
)

World:Entity(MakeDungeonRequest)
Diary.Write("Welcome to Svarog")

