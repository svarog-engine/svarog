
LoadPlayerSystem "InputActions"
LoadPlayerSystem "BumpMechanics"
LoadPlayerSystem "ResolveMove"

LoadEnviroSystem "DungeonMaker"
LoadEnviroSystem "DoorMechanics"

LoadRenderSystem "DungeonRender"
LoadRenderSystem "FadeOutRender"
LoadRenderSystem "TopLevelRender"
LoadRenderSystem "LogRender"
LoadRenderSystem "DebugRender"

World:Entity(
	Player, 
	Position{ x = 10, y = 10 },
	Glyph{ char = "@", fg = Colors.Yellow, bg = Colors.Black }
)

World:Entity(MakeDungeonRequest)
Diary.Write("Welcome to Svarog.")

