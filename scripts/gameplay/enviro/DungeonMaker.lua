
--local DungeonMakerSystem = Engine.RegisterEnviroSystem()

local function MakeDoor(x, y, closed, locked)
	if closed == nil then closed = true end
	if locked == nil then locked = false end

	local glyph = "door_closed"

	if not closed then 
		locked = false
		glyph = "door_open" 
	end

	Dungeon.floor:Set(x, y, { 
		type = Door, 
		pass = false, 
		entity = World:Entity(
			Glyph{ name = glyph },
			Door{ 
				closed = closed, 
				locked = locked
			}, 
			Position{ x = x, y = y }
		)
	})
end


local function AddItems()
	Dungeon.floor:Set(11, 10, {type = Item, pass = false, entity = World:Entity(
															Item{name = "Magic Sword"},
															Position{x = 11, y = 10},
															Glyph{name = "item"})})

	Dungeon.floor:Set(12, 10, {type = Item, pass = false, entity = World:Entity(
															Item{name = "The Magic Sword"},
															Position{x = 12, y = 10},
															Glyph{name = "item"})})
end
local function MakeDungeon()
	Dungeon.entities = {}
	Dungeon.passable = Map:New(Config.Width, Config.Height)
	Dungeon.passableWithEntities = Map:New(Config.Width, Config.Height)
	Dungeon.floor = Map:New(Config.Width, Config.Height)
		
	for i = 5, 15 do
		for j = 6, 12 do
			Dungeon.floor:Set(i, j, { type = Floor })
		end
	end

	MakeDoor(8, 13)
	MakeDoor(13, 13, true, true)

	for i = 14, 20 do 
		Dungeon.floor:Set(8, i, { type = Floor })
	end 
	
	AddItems()
	MakeDoor(9, 20)
	for i = 10, 33 do
		for j = 14, 25 do
			Dungeon.floor:Set(i, j, { type = Floor })
		end
	end

	Dungeon.playerDistance = Dungeon.floor:DijkstraByClass({ { Item, 0 } }, PassableInDungeon)
	Dungeon.created = true	
end

OnStartup(function() MakeDungeon() end)