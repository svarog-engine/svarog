
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

function SelectDungeonLevel(index)
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

local function FindPick(used, w, h, store, n, ne, bound, doors, hidden)
	if hidden == nil then hidden = false end

	local d = store:GetPosition(n) - store:GetPosition(ne)

	local dx = 0
	local dy = 0
	local dtx = 0
	local dty = 0
	local di = 0
	while true do
		local line = Geometry.MakeLine(math.floor(w / 2) + dx, math.floor(h / 2) + dy, math.floor(w / 2 + d.X + dtx), math.floor(h / 2 + d.Y + dty))
		local candidates = Geometry.Intersect(bound, line).Points
		local count = candidates.Count
		local picks = FromList(candidates)
		if count == 0 then 
			di = di + 1
			dx = dx + Rand:Range(-1, 2)
			dy = dy + Rand:Range(-1, 2)
			dtx = dtx + Rand:Range(-1, 2)
			dty = dty + Rand:Range(-1, 2)
		else
			for _, pick in ipairs(picks) do
				local index = pick.Y * Config.Width + pick.X
				if used[index] == nil then
					used[index] = true
					local door = { X = pick.X, Y = pick.Y, Neighbor = ne, Hidden = hidden }
					table.insert(doors, door)
					break
				end
			end
			break
		end
	end
end

local function MakeDungeonX()
	PCG:Clear()
	PCG:LoadProcs("dungeon")
	PCG:RunProc("start", 4)
	PCG:RunProc("connect", 7)
	PCG:RunProc("entry", 1)
	PCG:RunProc("zone", 1)
	PCG:RunProc("branch", 2)
	PCG:RunProc("zone", 2)
	PCG:RunProc("hard", 5)
	PCG:RunProc("cleanup", 10)
	PCG:RunProc("tempconn", 5)
	PCG:RunProc("tempsecret", 3)
	PCG:RunProc("template", 10)
	PCG:RunProc("secrets", 10)
	PCG:RunProc("exit", 1)
	PCG:RunProc("secrets", 1)
	PCG:RunProc("intro", 5)
	PCG:RunProc("intronopelock", 5)
	PCG:RunProc("badlock", 5)	
	PCG:EmitDot()

	local store = PCG:Storage()

	Dungeons = {}
	Dungeons.maps = {}

	local entry = nil

	for _, n in pairs(FromList(store.Nodes)) do
		if store:GetAnnotation(n) == "ENTRY" then
			entry = n
		end

		local w, h = Config.Width, Config.Height
		Dungeons.maps[n] = {}
		Dungeons.maps[n].index = n
		Dungeons.maps[n].name = store:GetAnnotation(n)
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

		for _, ne in pairs(FromList(store:ListOutNeighbors(n))) do
			FindPick(used, w, h, store, n, ne, bound, doors)
		end

		for _, ne in pairs(FromList(store:ListInNeighbors(n))) do
			FindPick(used, w, h, store, n, ne, bound, doors, true)
		end

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

	if entry ~= nil then
		SelectDungeonLevel(entry)
	end
end

function InitDungeonLevel(id, width, height, revert)
	if width == nil then width = Config.Width end
	if height == nil then height = Config.Height end
	if revert == nil then revert = false end
	local oldDungeon = Dungeon
	Dungeons.maps[id] = {}
	Dungeon = Dungeons.maps[id]
	Dungeon.index = id
	Dungeon.width = width
	Dungeon.height = height
	Dungeon.name = "Level"
	Dungeon.entities = {}
	Dungeon.entitiesList = {}
	Dungeon.passable = Map:New(width, height)
	Dungeon.floor = Map:New(width, height, nil)
	Dungeon.visibility = Map:New(width, height, 0)
	Dungeon.visited = Map:New(width, height, 0)
	
	SelectDungeonLevel(id)

	if revert then 
		Dungeon = oldDungeon
	end
end

local function InitDungeonLevels()
	Dungeons = {}
	Dungeons.maps = {}

	InitDungeonLevel(1)
end

local function FinishDungeons()
	Dungeons.created = true
end


local function DungeonSize()
	return Dungeon.width, Dungeon.height
end

local function Rasterize(what)
	local bound = Geometry.Boundary(what)
	local pts = Geometry.Surface(what).Points:GetEnumerator()
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
end

local function MakeDungeon()
	InitDungeonLevels()
	
	local w, h = DungeonSize()
	local level = nil
	for i = 1, 100 do
		local roomWidth, roomHeight = Rand:Range(4, 10), Rand:Range(4, 8)
		local room = Geometry.MakeRect(Rand:Range(2, w - roomWidth - 2), Rand:Range(2, h - roomHeight - 7), roomWidth, roomHeight)
		if level == nil then
			level = room
		else
			if Geometry.Intersect(Geometry.Discrete(level), room).Points.Count == 0 then
				level = Geometry.Union(level, room)
			end
		end
	end
	Rasterize(level)
	
	local invertLevel = Map:Invert(Dungeon.floor)
	Dungeons.playerDistance = DistanceMap:From(invertLevel, { { math.floor(Config.Width / 2), math.floor(Config.Height / 2) } }, 0)
	Dungeons.playerDistance:AddCondition(DistanceMap.IS_FLOOR)
	Dungeons.playerDistance:Flood()
	FinishDungeons()
end

OnStartup(function() MakeDungeon() end)