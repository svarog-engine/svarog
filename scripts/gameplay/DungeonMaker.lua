
function AddEntityToDungeon(x, y, entity)
	if Dungeon.floor ~= nil then
		local id = Dungeon.floor:ID(x, y)
		if Dungeon.entities[id] == nil then
			Dungeon.entities[id] = {}
		end

		table.insert(Dungeon.entities[id], entity)
	end
end

local function RemoveEntity(x, y, entity)
	if Dungeon.floor ~= nil then
		local id = Dungeon.floor:ID(x, y)
		if Dungeon.entities[id] ~= nil then
			for i, e in ipairs(Dungeon.entities[id]) do
				if e == entity then
					table.remove(Dungeon.entities[id], i)
					break
				end
			end
		end	
	end
end

function RemoveEntityFromDungeon(entity)
	RemoveEntity(entity[Position].x, entity[Position].y, entity)
end

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

local function MakeDungeon()
	Dungeon.entities = {}
	Dungeon.passable = Map:New(Config.Width, Config.Height)
	Dungeon.floor = Map:New(Config.Width, Config.Height, nil)

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
	
	MakeDoor(9, 20)
	for i = 10, 33 do
		for j = 14, 25 do
			Dungeon.floor:Set(i, j, { type = Floor })
		end
	end

	Dungeon.playerDistance = DistanceMap:From(Dungeon.floor, { { 10, 10 } }, 0)
	Dungeon.playerDistance:AddCondition(DistanceMap.IS_FLOOR)
	Dungeon.playerDistance:AddCondition(DistanceMap.IS_OPEN_DOOR)
	Dungeon.playerDistance:Flood()
	Dungeon.created = true
end

OnStartup(function() MakeDungeon() end)