
World:Entity(Player, Position({ x = 10, y = 10 }))
World:Entity(MakeDungeonRequest)

dofile "scripts\\player\\InputActions.lua"
dofile "scripts\\player\\BumpMechanics.lua"
dofile "scripts\\player\\ResolveMove.lua"

dofile "scripts\\enviro\\DungeonMaker.lua"
dofile "scripts\\enviro\\DoorMechanics.lua"

dofile "scripts\\render\\DungeonRender.lua"
dofile "scripts\\render\\DebugRender.lua"
dofile "scripts\\render\\FadeOutRenderer.lua"
dofile "scripts\\render\\LogRender.lua"

Diary.Write("Welcome to Svarog.")

