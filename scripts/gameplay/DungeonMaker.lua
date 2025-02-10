
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

local function MakeDoor(x, y, closed, locked, key)
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
			Position{ x = x, y = y },
			Key { item = key }
		)
	})
end

local function MakeSingleDungeon(name)
	Dungeon = Dungeons.maps[name]
	print("DUNGEON: ", Dungeon.floor:Has(math.floor(Config.Width / 2), math.floor(Config.Height / 2)))
	Dungeons.playerDistance = DistanceMap:From(Dungeon.floor, { { math.floor(Config.Width / 2), math.floor(Config.Height / 2) } }, 0)
	Dungeons.playerDistance:AddCondition(DistanceMap.IS_FLOOR)
	Dungeons.playerDistance:AddCondition(DistanceMap.IS_OPEN_DOOR)
	Dungeons.playerDistance:Flood()
	Dungeons.created = true
end

local function MakeDungeon()
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
		print(n, store:GetPosition(n))
		if store:GetAnnotation(n) == "ENTRY" then
			entry = n
		end

		local w, h = Config.Width, Config.Height
		Dungeons.maps[n] = {}
		Dungeons.maps[n].name = store:GetAnnotation(n)
		Dungeons.maps[n].entities = {}
		Dungeons.maps[n].passable = Map:New(Config.Width, Config.Height)
		Dungeons.maps[n].floor = Map:New(Config.Width, Config.Height, nil)

		Dungeons.maps[n].visibility = Map:New(Config.Width, Config.Height, 0)
		if DebugToggle_FOV then 
			Dungeons.maps[n].visited = Map:New(Config.Width, Config.Height, 0)
		else
			Dungeons.maps[n].visited = Map:New(Config.Width, Config.Height, 1)
		end

		for i = math.floor(w / 4), math.floor(3 * w / 4) do
			for j = math.floor(h / 4), math.floor(3 * h / 4) do
				Dungeons.maps[n].floor:Set(i, j, { type = Floor })
				Dungeons.maps[n].passable:Set(i, j, true)
				Dungeons.maps[n].visibility:Set(i, j, 1)
			end
		end

		for _, ne in pairs(FromList(store:ListNeighbors(n))) do
			print(" ", ne, store:GetPosition(ne))
		end
	end

	if entry ~= nil then
		MakeSingleDungeon(entry)
	end
end

OnStartup(function() MakeDungeon() end)