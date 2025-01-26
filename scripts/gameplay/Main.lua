
LoadPlayerSystem "InputActions"
LoadPlayerSystem "BumpMechanics"
LoadPlayerSystem "ResolveMove"

LoadEnviroSystem "DungeonMaker"
LoadEnviroSystem "DoorMechanics"

LoadRenderSystem "DungeonRender"
LoadRenderSystem "FadeOutRender"
LoadRenderSystem "TopLevelRender"
LoadRenderSystem "LogRender"

World:Entity(
	Player, 
	Position{ x = 10, y = 10 },
	Glyph{ name = "mage" }
)

World:Entity(MakeDungeonRequest)
--Diary.Write("Welcome to Svarog.")

