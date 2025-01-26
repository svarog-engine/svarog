
LoadPlayerSystem "InputActions"
LoadPlayerSystem "BumpMechanics"
LoadPlayerSystem "ResolveMove"

LoadEnviroSystem "DungeonMaker"
LoadEnviroSystem "DoorMechanics"

LoadRenderSystem "DungeonRender"
LoadRenderSystem "FadeOutRender"
LoadRenderSystem "PlayerLightRender"
LoadRenderSystem "TopLevelRender"
LoadRenderSystem "LogRender"

World:Entity(
	Player, 
	Position{ x = 10, y = 10 },
	Glyph{ name = "mage" }
)

World:Entity(
	Creature, 
	Position{ x = 14, y = 7 },
	Glyph{ name = "gob1" }
)

World:Entity(MakeDungeonRequest)
Diary.Write("Welcome to Svarog")

