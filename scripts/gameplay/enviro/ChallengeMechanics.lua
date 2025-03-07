
local ChallengeSystem = Engine.RegisterEnviroSystem("Challenge System")

local function ActiveWordsCount(entity)
	local count = 0
	for i = 1, 12 do
		local _, component = Wheels:GetMajor(i)
		if entity[component] ~= nil then count = count + 1 end
		local _, component = Wheels:GetMinor(i)
		if entity[component] ~= nil then count = count + 1 end
	end

	return count
end

local SpawnDeltaLocations = {}
SpawnDeltaLocations[0] = { {  0,  0 } }
SpawnDeltaLocations[1] = { {  0, -3 } }
SpawnDeltaLocations[2] = { {  0, -3 }, {  0,  3 } }
SpawnDeltaLocations[3] = { {  0,  3 }, { -4, -2 }, {  4, -2 } }
SpawnDeltaLocations[4] = { { -3, -3 }, { -3,  3 }, {  3, -3 }, {  3, 3 } }
SpawnDeltaLocations[5] = { {  0, -5 }, {  5, -2 }, { -5, -2 }, { -4, 4 }, { 4, 4 } }

local function SpawnChallengeEntities(x, y, n, challenge)
	PCExplode(7, Colors.White, Colors.Magenta, function()
		local c = Geometry.Boundary(Geometry.MakeCircle(x, y, 6))
		local e = c.Points:GetEnumerator()

		while e:MoveNext() do
			local cx, cy = e.Current.X, e.Current.Y
			if Dungeon.floor:Has(cx, cy) and Dungeon.floor:Get(cx, cy).type == Floor then
				local id = Dungeon.floor:ID(cx, cy)
				local entts = Dungeon.entities[id] or {}
				
				Procgen.MakeObject("Rift", cx, cy, challenge)
			end
		end

		local locs = SpawnDeltaLocations[n]
		local ko = 0
		for _, l in ipairs(locs) do
			local lx, ly = x + l[1], y + l[2]
			local lid = Dungeon.floor:ID(lx, ly)
			if Dungeon.floor:Has(lx, ly) and Dungeon.passable:Get(lx, ly) then
				local entts = Dungeon.entities[lid] or {}
				if #entts == 0 then
					Procgen.MakeObject("Portal", lx, ly, challenge)
				else 
					ko = ko + 1
				end
			end
		end

		if ko > 0 then
			Diary.Write("Some portals failed to open. Tension subsides.")
			local tension = PlayerEntity[Tension]
			tension:Down(ko * 3)
		end
	end)
end

function ChallengeSystem:ShouldTick()
	return Dungeons.created and PlayerEntity ~= nil
end

function ChallengeSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Challenged, Position, Player)):Iterator() do
		local challengeLevel = ActiveWordsCount(entity)
		
		local position = entity[Position]

		local challengeEntity = World:Entity(MagicChallenge { time = 0, difficulty = challengeLevel })
		SpawnChallengeEntities(position.x, position.y, challengeLevel, challengeEntity.id)

		entity:Unset(Challenged)
	end

	for _, entity in World:Exec(ECS.Query.All(MagicChallenge)):Iterator() do
		local challenge = entity[MagicChallenge]
		local position = PlayerEntity[Position]
		challenge.time = challenge.time + 1
		if challenge.time > 6 then
			PlayerEntity[Tension]:Down(1) 

			for _, re in World:Exec(ECS.Query.All(Magic, Dependent).None(Timeout)):Iterator() do
				if re[Dependent].value == entity.id then
					RemoveEntityFromDungeon(re)
					World:Remove(re)
					Dungeon.memory:Set(re[Position].x, re[Position].y, false)
					Dungeon.passable:Set(re[Position].x, re[Position].y, true)
				end
			end

			RemoveEntityFromDungeon(entity)
			World:Remove(entity)
		end
	end

	for _, entity in World:Exec(ECS.Query.All(Timeout)):Iterator() do
		local timeout = entity[Timeout]
		timeout.value = timeout.value - 0.5

		if timeout.value < 0 then
			RemoveEntityFromDungeon(entity)
			World:Remove(entity)
		end
	end
end