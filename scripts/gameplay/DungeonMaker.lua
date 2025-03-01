
function AddEntityToDungeon(x, y, entity)
	if Dungeon == nil then
		Svarog.Instance:LogError("Adding failed: Dungeon nil")
		return nil
	end

	if Dungeon.floor ~= nil then
		local id = Dungeon.floor:ID(x, y)
		if Dungeon.entities[id] == nil then
			Dungeon.entities[id] = {}
		end

		table.insert(Dungeon.entities[id], entity)
		table.insert(Dungeon.entitiesList, entity)
		return entity
	else
		Svarog.Instance:LogError("Adding failed: no floor")
		return nil
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

			for i, e in ipairs(Dungeon.entitiesList) do
				if e == entity then
					table.remove(Dungeon.entitiesList, i)
					break
				end
			end
		end	
	end
end

function RemoveEntityFromDungeon(entity)
	RemoveEntity(entity[Position].x, entity[Position].y, entity)
end

local function MakeDoor(x, y, closed, locked, key, travelTo)
	if closed == nil then closed = true end
	if locked == nil then locked = false end

	local glyph = "door_closed"

	if not closed then 
		locked = false
		glyph = "door_open" 
	end

	local entity = World:Entity(
		Glyph{ name = glyph },
		Door{
			closed = closed, 
			locked = locked,
			travelTo = travelTo,
		}, 
		Position{ x = x, y = y },
		Key { item = key }
	)

	AddEntityToDungeon(x, y, entity)

	Dungeon.floor:Set(x, y, { 
		type = Door, 
		pass = false,
		entity = entity
	})

	return entity
end

function FindDoorTo(index)
	for i, e in ipairs(Dungeon.entitiesList) do
		local door = e[Door]
		if door ~= nil then
			if door.travelTo == index then
				return e
			end
		end
	end
	return nil
end

function MakeDungeonRoom(index)
	Dungeon = Dungeons.maps[index]
	Dungeons.playerDistance = DistanceMap:From(Dungeon.floor, { { PlayerEntity[Position].x, PlayerEntity[Position].y } }, 0)
	Dungeons.playerDistance:AddCondition(DistanceMap.IS_FLOOR)
	Dungeons.playerDistance:AddCondition(DistanceMap.IS_OPEN_DOOR)
	Dungeons.playerDistance:Flood()
	Dungeons.created = true
end

local function signum(number)
   if number > 0 then
      return 1
   elseif number < 0 then
      return -1
   else
      return 0
   end
end

local function MakeDungeon()	
	Dungeons = {}
	Dungeons.maps = {}
	Dungeons.created = true

	local w, h = Config.Width, Config.Height
	Dungeons.maps[1] = {}
	Dungeons.maps[1].index = 1
	Dungeons.maps[1].name = "Room" .. 1
	Dungeons.maps[1].entities = {}
	Dungeons.maps[1].entitiesList = {}
	Dungeons.maps[1].passable = Map:New(Config.Width, Config.Height)
	Dungeons.maps[1].floor = Map:New(Config.Width, Config.Height, nil)
	Dungeons.maps[1].visibility = Map:New(Config.Width, Config.Height, 0)
	if DebugToggle_FOV then 
		Dungeons.maps[1].visited = Map:New(Config.Width, Config.Height, 0)
	else
		Dungeons.maps[1].visited = Map:New(Config.Width, Config.Height, 1)
	end
		
	Dungeon = Dungeons.maps[1]
	local m1 = Markov:Run("DijkstraDungeon", Config.Width, Config.Height - 4)
	local m2 = Markov:Or(m1, "SmarterDigger", Config.Width, Config.Height - 4, 250)
	local m3 = Markov:Or(m2, "SmarterDigger", Config.Width, Config.Height - 4, 250)
	local m = Map:From(m3, Config.Width)
	local ok = {}
	local values = {}
	for i = 1, Config.Width do
		for j = 1, Config.Height - 4 do 
			local v = m:Get(i, j)
			if values[v] == nil then values[v] = 1 end
			local ij = { i, j }
			
			if v == 1 or v == 2 then
				Dungeon.floor:Set(i, j, { type = Floor })
				table.insert(ok, ij)
			else
				Dungeon.floor:Set(i, j, { type = Wall })
			end
		end
	end
	for k, _ in pairs(values) do print(k) end
	local xy = ok[Rand:Range(1, #ok)]
		
	PlayerEntity = World:Entity(
		Player(),
		Position{ x = xy[1], y = xy[2] },
		Glyph{ name = "mage" },
		Inventory{ items = {}}
	)
	
	Dungeons.playerDistance = DistanceMap:From(Dungeon.floor, { { PlayerEntity[Position].x, PlayerEntity[Position].y } }, 0)
	Dungeons.playerDistance:AddCondition(DistanceMap.IS_FLOOR)
	Dungeons.playerDistance:AddCondition(DistanceMap.IS_OPEN_DOOR)
	Dungeons.playerDistance:Flood()
	Dungeons.created = true
end

OnStartup(function() MakeDungeon() end)