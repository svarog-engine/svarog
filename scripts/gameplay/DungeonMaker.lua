
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
	if entity[Position] ~= nil then
		RemoveEntity(entity[Position].x, entity[Position].y, entity)
	end
end

function SelectDungeonLevel(index)
	Dungeon = Dungeons.maps[index]
	PlayerEntity[Position].x = Dungeon.start[1]
	PlayerEntity[Position].y = Dungeon.start[2]
	Dungeon.playerDistance = DistanceMap:From(Dungeon.floor, { { PlayerEntity[Position].x, PlayerEntity[Position].y } }, 0)
	Dungeon.playerDistance:AddCondition(function(map, x, y) return Dungeon.passable:Has(x, y) and Dungeon.passable:Get(x, y) end)
	Dungeon.playerDistance:Flood()
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
			"My people only prowl around slowlike. You also <SHIFT>!",
			"There were NINE shards that we held before the curse.",
			"If you tire, find <SPACE> to RECOUP, to take VANTAGE.",
			"FOUR breaths snap the TENSION, our forefathers have said.",
			"SHARDs give us GLYPHs of power. They do as they please.",
			"My sorry people has to burden you so... Do as we couldn't.",
			"There are FOUR ALTARS to cross before the one we HATE.",
			"Go and seal what lies BENEATH THE THRONE OF OUR QUEEN.",
			"PLANTS alleviate TENSION from the GLYPH they are bound to.",
			"Each MINERAL refracts a GLYPH: throw it to bestow essences.",
			"Due to the TENSION of the GLYPHS, the RELEASE mana, satia...",
			"...ting the ALTAR should open a path to new powers!",
			"Rift PORTALS are easy to close -- make any physical contact!",
			"We have seen patterns, patterns persist even when we don't.",
			"Each GLYPH is a boon, their balance cradles our world.",
			"There is none who survived the RIFTS and what they BRING.",
			"The magics of the GLYPHs are varied and unmeasurable.",
			"Satiate the ALTARS in a RELEASE OF TENSION to open them.",
			"This one ALTAR we have readied for you, dear savior. ENDURE.",
			"May our LIBRARIES be useful to your efforts...",
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

		print(Dungeon.creatureCount)
		
		return centers
	elseif l == 5 then
		local bucketIndex = Dungeon.wallDistances:GetHighestBucket()
		local bucket = Dungeon.wallDistances:GetAt(bucketIndex)
		r = Rand:Range(1, #bucket)
		local rx, ry = math.floor(bucket[r].x), math.floor(bucket[r].y)
		Procgen.MakeObject("SatiatedAltar", rx, ry, "Hate")
		Procgen.MakeObject("Throne", rx - 1, ry + 3)
		
		return { { math.floor(w / 2), math.floor(h / 2) } }
	elseif l == 6 then
		local bucketIndex = Dungeon.wallDistances:GetHighestBucket()
		local bucket = Dungeon.wallDistances:GetAt(bucketIndex)
		r = Rand:Range(1, #bucket)
		local rx, ry = math.floor(bucket[r].x), math.floor(bucket[r].y)
		Procgen.MakeObject("Skeleton", rx + 1, ry + 1)
		return { { math.floor(w / 2), math.floor(h / 2) } }
	end
end

function MakeDungeon()
	local w, h = Config.Width - 16, Config.Height - 4

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
	Dungeon = Dungeons.maps[Level]
	
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