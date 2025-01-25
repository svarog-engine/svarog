
LoadPlayerSystem "InputActions"
LoadPlayerSystem "BumpMechanics"
LoadPlayerSystem "ResolveMove"

LoadEnviroSystem "DungeonMaker"
LoadEnviroSystem "DoorMechanics"

LoadRenderSystem "DungeonRender"
LoadRenderSystem "DebugRender"
LoadRenderSystem "FadeOutRenderer"
LoadRenderSystem "LogRender"

World:Entity(Player, Position({ x = 10, y = 10 }))
World:Entity(MakeDungeonRequest)
Diary.Write("Welcome to Svarog.")

