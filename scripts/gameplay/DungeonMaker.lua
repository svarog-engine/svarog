function SelectDungeonLevel(index)
	Dungeon = Dungeons.maps[index]
	PlayerEntity[Position].x = Dungeon.start[1]
	PlayerEntity[Position].y = Dungeon.start[2]
	Dungeon.playerDistance = DistanceMap:From(Dungeon.floor, { { PlayerEntity[Position].x, PlayerEntity[Position].y } }, 0)
	Dungeon.playerDistance:AddCondition(function(map, x, y) return Dungeon.passable:Has(x, y) and Dungeon.passable:Get(x, y) end)
	Dungeon.playerDistance:Flood()

	Dungeon.playerDistanceEmpty = DistanceMap:From(Dungeon.floor, { { PlayerEntity[Position].x, PlayerEntity[Position].y } }, 0)
	Dungeon.playerDistanceEmpty:AddCondition(function(map, x, y) 
		local id = Dungeon.floor:ID(x, y)
		local entts = Dungeon.entities[id] or {}
		return #entts == 0 and Dungeon.passable:Has(x, y) and Dungeon.passable:Get(x, y)
	end)
	Dungeon.playerDistanceEmpty:Flood()

	Dungeon.creatureDistance = DistanceMap:From(Dungeon.floor, {}, 0)
	Dungeon.creatureDistance:AddCondition(function(map, x, y) return Dungeon.passable:Has(x, y) and Dungeon.passable:Get(x, y) end)
	Dungeon.itemDistance = DistanceMap:From(Dungeon.floor, {}, 0)
	Dungeon.itemDistance:AddCondition(function(map, x, y) return Dungeon.passable:Has(x, y) and Dungeon.passable:Get(x, y) end)
	
	Dungeon.created = true
end

-- make shell 
--  012
--  783
--  654
local function Snail(x, y)
    local lookup = {
        [0] = {[0] = 0, [1] = 7, [2] = 6},
        [1] = {[0] = 1, [1] = 8, [2] = 5},
        [2] = {[0] = 2, [1] = 3, [2] = 4}
    }
    
    return lookup[x] and lookup[x][y] or nil
end

Level = 0

local function GenerateSpecificShape(l, w, h)
	if l == 1 then
		return Map:From(Markov:Run("Growth", w, h, 200), w)
	elseif l < 5 then
		local m1 = Markov:Run("StrangeDungeon", w, h)
		local m2 = Markov:Or(m1, "DijkstraDungeon", w, h)
		local m3 = Markov:Or(m2, "SelectLargeCaves", w, h, 2000, 2)
		return Map:From(m3, w)
	elseif l == 5 then
		local m1 = Markov:Run("StrangeDungeon", w, h)
		return Map:From(Markov:Or(m1, "Growth", w, h, 800), w)
	elseif l == 6 then
		return Map:From(Markov:Run("Growth", w, h, 1000), w)
	end
end

local function SpecificRoomSetup(l, w, h)
	if l == 1 then		
		local bucketIndex = Dungeon.wallDistances:GetHighestBucket()
		local bucket = Dungeon.wallDistances:GetAt(bucketIndex)
		r = Rand:Range(1, #bucket)
		local rx, ry = math.floor(bucket[r].x), math.floor(bucket[r].y)
		local comps = OtherComps({})
		Procgen.MakeObject("SatiatedAltar", rx, ry, "Endure")

		local messages = {
			"My people prowl around slowlike. You can <SHIFT>!",
			"Tired? Find <SPACE> to RECOUP, to OBSERVE.",
			"FOUR breaths snap the TENSION! <SPACE> to breathe.",
			"GLYPHs of power. They do as they please.",
			"FOUR ALTARS to cross before the one we HATE.",
			"PLANTS give us slivers of the boons of GLYPHs.",
			"MINERALs paralyze what isn't bound.",
			"Rift PORTALS are easy to close: just touch them!",
			"Patterns persist even when we don't.",
			"Satiate the ALTARS in TENSION to open them.",
			"One ALTAR we have readied for you. ENDURE.",
			"Our libraries will tell you of the many bindings!",
		}
		
		local bucket = Dungeon.wallDistances:GetAt(3)
		for _, v in ipairs(Dungeon.wallDistances:GetAt(2)) do
			table.insert(bucket, v)
		end 

		for _, message in ipairs(messages) do
			r = Rand:Range(1, #bucket)
			local rx, ry = math.floor(bucket[r].x), math.floor(bucket[r].y)
			table.remove(bucket, r)
			Procgen.MakeObject("Book", rx, ry, message)
		end

		return { { math.floor(w / 2), math.floor(h / 2) } }

	elseif l < 5 then
		local centers = {}
		local bucketIndex = Dungeon.wallDistances:GetHighestBucket()
		local halfsteps = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
	
		table.remove(halfsteps, Rand:Range(1, #halfsteps))
		table.remove(halfsteps, Rand:Range(1, #halfsteps))
		table.remove(halfsteps, Rand:Range(1, #halfsteps))

		local specials = 1
		local rest = OtherComps(PlayerEntity[Boons].value)
		local w3, h3 = math.ceil(w / 3), math.ceil(h / 3)

		local numberOfKeys = math.ceil(Dungeon.numberOfChests / 2)
		if numberOfKeys <= 0 then numberOfKeys = 1 end
		print("Generating " .. numberOfKeys .. " for " .. Dungeon.numberOfChests .. " chests")
		while bucketIndex > 0 do
			local usedRs = {}

			for i = 0, 100 do
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
					local cx, cy = math.floor(rx / w3), math.floor(ry / h3)

					if specials > 0 then
						local ri = Rand:Range(1, #rest)
						Procgen.MakeObject("Altar", rx - 1, ry, rest[ri])
						table.remove(rest, ri)
						local ri = Rand:Range(1, #rest)
						Procgen.MakeObject("Altar", rx + 1, ry, rest[ri])
						table.remove(rest, ri)
						specials = specials - 1
					elseif numberOfKeys > 0 then
						Procgen.MakeObject("Key", rx, ry)
						numberOfKeys = numberOfKeys - 1
					else
						local name, comp = Wheels:GetMajor(halfsteps[(Snail(cx, cy) or 1 + i) % 9 + 1])
						local roomTemplates = Rooms[comp]
						local roomTemplate = roomTemplates[Rand:Range(0, #roomTemplates)]
				
						if roomTemplate ~= nil then
							Templates[roomTemplate](rx, ry)
						end
					end
				end
			end

			bucketIndex = bucketIndex - 1
		end
		
		return centers
	elseif l == 5 then
		local bucketIndex = Dungeon.wallDistances:GetHighestBucket()
		local bucket = Dungeon.wallDistances:GetAt(bucketIndex)
		r = Rand:Range(1, #bucket)
		local rx, ry = math.floor(bucket[r].x), math.floor(bucket[r].y)
		Procgen.MakeObject("SatiatedAltar", rx, ry, "Hate")
		Procgen.MakeObject("Skeleton", rx + 1, ry + 2)
		Procgen.MakeObject("Throne", rx - 1, ry)
		return { { math.floor(w / 2), math.floor(h / 2) } }
	elseif l == 6 then
		local bucketIndex = Dungeon.wallDistances:GetHighestBucket()
		local bucket = Dungeon.wallDistances:GetAt(bucketIndex)
		for i, f in ipairs(bucket) do
			local rx, ry = math.floor(bucket[i].x), math.floor(bucket[i].y)	
			Procgen.MakeObject("Portal", rx, ry, 5, Rand:Range(2, 4), PlayerEntity[Boons].value[Rand:Range(1, #PlayerEntity[Boons].value)])
		end		
		return { { math.floor(w / 2), math.floor(h / 2) } }
	end
end

function MakeDungeon()
	local w, h = Config.Width - 16, Config.Height - 5

	local old = false
	if Dungeon ~= nil then
		old = true
		for _, e in ipairs(Dungeon.entitiesList) do
			if e ~= PlayerEntity then
				RemoveEntityFromDungeon(e)
				World:Remove(e)
			end
		end
	end

	Level = Level + 1
	Dungeons.maps[Level] = {}
	SetDressing = {}
	Dungeon = Dungeons.maps[Level]
	Dungeon.numberOfChests = 0
	Dungeon.creatureCount = 0
	Dungeon.index = Level
	Dungeon.name = "Level" .. Level
	Dungeon.entities = {}
	Dungeon.entitiesList = {}
	Dungeon.passable = Map:New(w, h)
	Dungeon.memory = Map:New(w, h)
	Dungeon.floor = Map:New(w, h, nil)
	Dungeon.visibility = Map:New(w, h, false)
	Dungeon.visited = Map:New(w, h, false)
	
	local m = GenerateSpecificShape(Level, w, h)

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
	local centers = SpecificRoomSetup(Level, w, h)

	-- QUIET ZONES

	Dungeon.quiet = DistanceMap:From(Dungeon.floor, centers, 0)
	Dungeon.quiet:AddCondition(DistanceMap.IS_FLOOR)
	Dungeon.quiet:Flood()

	if Level ~= 1 and Level ~= 5 then
		local crs = { "Goblin", "Kobold", "Hobgob" }
		while Dungeon.creatureCount < 20 do
			local x, y = Rand:Range(1, w), Rand:Range(1, h)
			if Dungeon.floor:Has(x, y) and Dungeon.floor:Get(x, y).type == Floor then
				Procgen.MakeObject(crs[Rand:Range(1, #crs)], x, y)
			end
		end
	end

	local mostQuiet = Dungeon.quiet:GetHighestBucket()
	local ok = Dungeon.quiet:GetAt(mostQuiet)
	local xy = ok[Rand:Range(1, #ok)]
	local x, y = xy.x, xy.y
	Dungeon.start = { x , y }

	-- PLAYER SETUP

	if old then
		SelectDungeonLevel(Level)
		PlayerDone = true
	else
		PlayerEntity = World:Entity(
			Player(),
			Boons{ value = {} },
			MoveMode("Walk"),
			Sight(5),
			Pause(),
			ID(-1),
			Position{ x = x, y = y },
			Glyph{ name = "mage" },
			Contents{ items = {} },
			Health(Range(9, 9)),
			BumpAttack { damage = 2 },
			Name("you"),
			Stamina(Range(9, 9)),
			Tension(Range(0, 9)),
			Burnable()
		)
	
		LootTable = World:Entity(LootInventory{ target = nil })

		Dungeon.visited:Set(x, y, true)
		SelectDungeonLevel(Level)
	end
end

local function MakeWheels()
	local majorStart = Rand:Range(1, 12)
	local minorStart = Rand:Range(1, 12)
	
	Dungeons.wheels = CreateWheels(majorStart, minorStart)
	for i = 1, 12 do
		local man, mam = Dungeons.wheels:GetMajor(i)
		local min, mim = Dungeons.wheels:GetMinor(i)
	end
end

OnStartup(function() 
	Level = 0

	if PlayerEntity ~= nil then
		Dungeon = nil
		RemoveEntityFromDungeon(PlayerEntity)
		World:Remove(PlayerEntity)
		PlayerEntity = nil
	end

	Dungeons = {}
	Dungeons.maps = {}
	Dungeons.created = true

	MakeWheels()
	MakeDungeon() 
	SelectDungeonLevel(1)
end)