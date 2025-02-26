
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
	Dungeons.playerDistance = DistanceMap:From(Dungeon.floor, { { math.floor(Config.Width / 2), math.floor(Config.Height / 2) } }, 0)
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

	for n = 1, 10 do
		local w, h = Config.Width, Config.Height
		Dungeons.maps[n] = {}
		Dungeons.maps[n].index = n
		Dungeons.maps[n].name = "Room" .. n
		Dungeons.maps[n].entities = {}
		Dungeons.maps[n].entitiesList = {}
		Dungeons.maps[n].passable = Map:New(Config.Width, Config.Height)
		Dungeons.maps[n].floor = Map:New(Config.Width, Config.Height, nil)
		Dungeons.maps[n].visibility = Map:New(Config.Width, Config.Height, 0)
		if DebugToggle_FOV then 
			Dungeons.maps[n].visited = Map:New(Config.Width, Config.Height, 0)
		else
			Dungeons.maps[n].visited = Map:New(Config.Width, Config.Height, 1)
		end
		
		Dungeon = Dungeons.maps[n]

		local shapes = {}

		if entry ~= n then
			for i = 1, Rand:Range(2, 5) do
				local x = Rand:Range(0, 3)
				local y = Rand:Range(0, 3)
				local wr = Rand:Range(5, 16)
				local hr = Rand:Range(4, 14)
				table.insert(shapes, Geometry.MakeRect(math.floor(x + w / 2 - wr), math.floor(y + h / 2 - hr), wr, hr))
			end
		else
			local r = Rand:Range(4, 7)
			table.insert(shapes, Geometry.MakeCircle(math.floor(w / 2), math.floor(h / 2), r))
			table.insert(shapes, Geometry.MakeRect(math.floor(w / 2), math.floor(h / 2), Rand:Range(4, 6), Rand:Range(3, 6)))
		end

		local union = Geometry.Union(table.unpack(shapes))
		local bound = Geometry.Boundary(union)
		local doors = {}
		local used = {}

		local pts = Geometry.Surface(union).Points:GetEnumerator()
		while pts:MoveNext() do
			local pt = pts.Current
			if bound.Points:Contains(pt) then
				Dungeon.floor:Set(pt.X, pt.Y, { type = Wall })
				Dungeon.passable:Set(pt.X, pt.Y, false)
			else
				Dungeon.floor:Set(pt.X, pt.Y, { type = Floor })
				Dungeon.passable:Set(pt.X, pt.Y, true)
			end
			Dungeon.visibility:Set(pt.X, pt.Y, true)
		end

		for _, door in ipairs(doors) do
			local doorEntity = MakeDoor(door.X, door.Y, true, false, nil, door.Neighbor)
			if door.Hidden then
				doorEntity.hidden = true
			end
		end
	end
end

OnStartup(function() MakeDungeon() end)