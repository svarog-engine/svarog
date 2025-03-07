
local ChallengeSystem = Engine.RegisterEnviroSystem("Challenge System")


local function GetWheelsEntries()
	local entries = {}
	for i = 1, 12 do
		name, component = Wheels:GetMajor(i)
		table.insert(entries, component)
	end

	for i = 1, 12 do
		name, component = Wheels:GetMinor(i)
		table.insert(entries, component)
	end

	return entries
end

function ActiveWordsCount(entity)
	local entries = GetWheelsEntries()
	local count = 0

	for _, component in pairs(entries) do
		if entity[component] ~= nil then
			count = count + 1
		end
	end

	return count
end

local function OnPlatformActivate(e)
	local challenge = e[ChallengeActive]
	challenge.activePlatforms = challenge.activePlatforms - 1

	DecreaseTension(e, 5)
end

local function SpawnChallengeEntities(x, y, n, challenge)
	for i = 1, n do

		local neighbours = { {i, 0}, {0, i}, {-i, 0}, {0, -i}, { -i, -i }, { i, -i }, { -i, i }, { i, i }}

		local positionFound = false
		local selected = nil
		for _, neighbour in ipairs(neighbours) do
			local dx, dy = table.unpack(neighbour)
			local nx = x + dx
			local ny = y + dy
			local pass = Dungeon.passable:Has(nx, ny) and Dungeon.passable:Get(nx, ny)
			local id = Dungeon.floor:ID(nx, ny)
			local entities = Dungeon.entities[id] or {}

			local somethingElse = false	
			for _, e in ipairs(entities) do
				if e ~= entity then
					somethingElse = true
					break
				end
			end

			if pass and not somethingElse then
				selected = {x = nx, y = ny }
				break;
			end
		end

		if selected ~= nil then
			local e  = World:Entity(
				Position{ x = selected.x, y = selected.y },
				Glyph{ name = "platform" },
				Name("Magic Circle"),
				Platform { challenge = challenge }
			)
		else
			n = n + 1
		end
	end
end

function ChallengeSystem:ShouldTick()
	return Dungeons.created and PlayerEntity ~= nil
end

function ChallengeSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Challenged, Position, Player)):Iterator() do

		local challengeLevel = ActiveWordsCount(entity) + 1

		if challengeLevel > 0 then

			local position = entity[Position]

			local challengeEntity = World:Entity(MagicChallenge { time = 2 * challengeLevel, difficulty = challengeLevel })
			SpawnChallengeEntities(position.x, position.y, challengeLevel, challengeEntity.id)
		end

		entity:Unset(Challenged)
	end

	for _, entity in World:Exec(ECS.Query.All(MagicChallenge)):Iterator() do
		local challenge = entity[MagicChallenge]
		local position = PlayerEntity[Position]
		challenge.time = challenge.time - 1

		print("Challenge time: " , challenge.time)

		if challenge.time == 0 then
			
			if challenge.difficulty > 0 then
				local cd = challenge.difficulty
				if cd > 10 then
					cd = 10
				end

				local neighbours = { { -1, 0 }, { 1, 0 }, { 0, 1 }, { 0, -1 }, { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }
				for _, neighbour in ipairs(neighbours) do
					local dx, dy = table.unpack(neighbour)
					local nx = position.x + dx
					local ny = position.y + dy
					local pass = Dungeon.passable:Has(nx, ny) and Dungeon.passable:Get(nx, ny)

					if pass and Chances[cd]:MakeGuess() then 
						Procgen.MakeObject("Flame", nx, ny, 10, 5)
					end
				end
			end

			for _, p in World:Exec(ECS.Query.All(Platform)):Iterator() do
				if p[Platform].challenge == entity.id then
					local position = p[Position]
					Procgen.MakeObject("Flame", position.x, position.y, 10, 5)
					RemoveEntityFromDungeon(p)
					World:Remove(p)
				end
			end

			PlayerEntity[Tension]:Down(5)

			RemoveEntityFromDungeon(entity)
			World:Remove(entity)
		end
	end
end