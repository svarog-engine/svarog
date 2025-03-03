
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
	Dungeon.playerDistance = DistanceMap:From(Dungeon.floor, { { PlayerEntity[Position].x, PlayerEntity[Position].y } }, 0)
	Dungeon.playerDistance:AddCondition(DistanceMap.IS_FLOOR)
	Dungeon.playerDistance:AddCondition(DistanceMap.IS_OPEN_DOOR)
	Dungeon.playerDistance:Flood()
	Dungeon.created = true
end

local function MakeDungeon()	
	Dungeons = {}
	Dungeons.maps = {}
	Dungeons.created = true

	local w, h = Config.Width - 16, Config.Height - 4

	Dungeons.maps[1] = {}
	Dungeon = Dungeons.maps[1]

	Dungeon.index = 1
	Dungeon.name = "Room" .. 1
	Dungeon.entities = {}
	Dungeon.entitiesList = {}
	Dungeon.passable = Map:New(w, h)
	Dungeon.floor = Map:New(w, h, nil)
	Dungeon.visibility = Map:New(w, h, false)
	Dungeon.visited = Map:New(w, h, false)
	
	local m1 = Markov:Run("StrangeDungeon", w, h)
	local m2 = Markov:Or(m1, "DijkstraDungeon", w, h)
	local m3 = Markov:Or(m2, "SelectLargeCaves", w, h, 10000, 2)
	local m = Map:From(m3, w)

	for i = 1, w - 1 do
		m:Set(i, 1, 0)
		m:Set(i, h, 0)
	end

	for i = 1, h do
		m:Set(1, i, 0)
		m:Set(w, i, 0)
	end
	
	local values = {}
	local walls = {}
	
	for i = 1, w do
		for j = 1, h do
			local v = m:Get(i, j)
			if values[v] == nil then values[v] = 1 end
			local ij = { i, j }
			
			if v == 1 or v == 2 or v == 3 then
				Dungeon.passable:Set(i, j, true)
				Dungeon.floor:Set(i, j, { type = Floor })
			else
				Dungeon.passable:Set(i, j, false)
				Dungeon.floor:Set(i, j, { type = Wall })
				table.insert(walls, { i, j })
			end
		end
	end

	Dungeon.wallDistances = DistanceMap:From(Dungeon.floor, walls, 0)
	Dungeon.wallDistances:AddCondition(DistanceMap.IS_FLOOR)
	Dungeon.wallDistances:Flood()

	-- ROOM SETUP

	Dungeon.zones = Map:New(w, h, 0)

	local centers = {}
	local zoneId = 1
	local bucketIndex = Dungeon.wallDistances:GetHighestBucket()
	
	while bucketIndex > 0 do
		local usedRs = {}
		for i = 0, 8 + (10 - bucketIndex) do
			local bucket = Dungeon.wallDistances:GetAt(bucketIndex)
			if bucket ~= nil then
				local r = 1
				local attempts = 0
				repeat 
					r = Rand:Range(1, #bucket)
					attempts = attempts + 1
					if attempts > #bucket then
						break
					end
				until usedRs[r] == nil
				usedRs[r] = true

				local rx, ry = math.floor(bucket[r].x), math.floor(bucket[r].y)
				table.insert(centers, { rx, ry })

				local rise = DistanceMap:From(Dungeon.floor, { { rx, ry } }, 0, bucketIndex)
				rise:AddCondition(DistanceMap.IS_FLOOR)
				rise:Flood()

				local shape = nil
				if Rand:Range(0, 10) < 5 then
					shape = Geometry.MakeCircle(rx, ry, bucketIndex)
				else
					shape = Geometry.MakeRect(rx - bucketIndex, ry - bucketIndex, bucketIndex, bucketIndex)
				end

				local surf = Geometry.Surface(shape).Points:GetEnumerator()
				while surf:MoveNext() do
					local pt = surf.Current

					if rise:Get(pt.X, pt.Y) <= bucketIndex then
						local oldZone = Dungeon.zones:Get(pt.X, pt.Y)
						if (oldZone == 0) or (oldZone > 0 and Rand:Range(0, 10) < zoneId - oldZone) then
							Dungeon.zones:Set(pt.X, pt.Y, zoneId)
						end
					end
				end
				zoneId = zoneId + 1
				if zoneId > 12 then zoneId = 1 end
			end
		end

		bucketIndex = bucketIndex - 1
	end

	Dungeon.quiet = DistanceMap:From(Dungeon.floor, centers, 0)
	Dungeon.quiet:AddCondition(DistanceMap.IS_FLOOR)
	Dungeon.quiet:Flood()

	local mostQuiet = Dungeon.quiet:GetHighestBucket()
	local ok = Dungeon.quiet:GetAt(mostQuiet)
	local xy = ok[Rand:Range(1, #ok)]
	local x, y = xy.x, xy.y

	-- PLAYER SETUP

	PlayerEntity = World:Entity(
		Player(),
		Position{ x = x, y = y },
		Glyph{ name = "mage" },
		Contents{ items = {} }
	)
	
	Dungeon.visited:Set(x, y, true)

	Dungeon.playerDistance = DistanceMap:From(Dungeon.floor, { { PlayerEntity[Position].x, PlayerEntity[Position].y } }, 0)
	Dungeon.playerDistance:AddCondition(DistanceMap.IS_FLOOR)
	Dungeon.playerDistance:Flood()
	
	Dungeons.created = true
end

OnStartup(function() MakeDungeon() end)