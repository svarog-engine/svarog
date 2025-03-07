
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

local function SpawnChallengeEntities(x, y, n, challenge)
	local c = Geometry.Boundary(Geometry.MakeCircle(x, y, 5))
	local e = c.Points:GetEnumerator()

	while e:MoveNext() do
		local x, y = e.Current.X, e.Current.Y
		local id = Dungeon.floor:ID(x, y)
		local entts = Dungeon.entities[id] or {}
		
		Procgen.MakeObject("Rift", x, y, challenge)
	end
end

function ChallengeSystem:ShouldTick()
	return Dungeons.created and PlayerEntity ~= nil
end

function ChallengeSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Challenged, Position, Player)):Iterator() do

		local challengeLevel = ActiveWordsCount(entity) + 1
		if challengeLevel < 4 then challengeLevel = 4 end

		if challengeLevel > 0 then
			local position = entity[Position]

			local challengeEntity = World:Entity(MagicChallenge { time = 0, difficulty = challengeLevel })
			SpawnChallengeEntities(position.x, position.y, challengeLevel, challengeEntity.id)
		end

		entity:Unset(Challenged)
	end

	for _, entity in World:Exec(ECS.Query.All(MagicChallenge)):Iterator() do
		local challenge = entity[MagicChallenge]
		local position = PlayerEntity[Position]
		challenge.time = challenge.time + 1
		if challenge.time > 12 then
			PlayerEntity[Tension]:Down(1)

			for _, re in World:Exec(ECS.Query.All(Magic, Dependent)):Iterator() do
				if re[Dependent].value == entity.id then
					RemoveEntityFromDungeon(re)
					World:Remove(re)
					Engine.Glyph(re[Position].x, re[Position].y, "cinders")
					Dungeon.passable:Set(re[Position].x, re[Position].y, true)
				end
			end

			RemoveEntityFromDungeon(entity)
			World:Remove(entity)
		end
	end
end