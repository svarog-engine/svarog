
Player = ECS.Component()
Position = ECS.Component({ x = 0, y = 0 })

World:Entity(Player, Position({ x = 10, y = 10 }))

dofile "scripts\\player\\InputTest.lua"

dofile "scripts\\enviro\\DungeonMaker.lua"
World:Entity(CreateDungeon)

dofile "scripts\\render\\DungeonRender.lua"
dofile "scripts\\render\\DebugRender.lua"

