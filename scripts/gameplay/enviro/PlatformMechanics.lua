
local PlatformSystem = Engine.RegisterEnviroSystem("Platforms")

function PlatformSystem:ShouldTick()
	return Dungeons.created
end

function PlatformSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Platform, Position)):Iterator() do
		local position = entity[Position]
		local platform = entity[Platform]

		local id = Dungeon.floor:ID(position.x, position.y)
		local entities = Dungeon.entities[id] or {}

		for _, e in ipairs(entities) do
			if e ~= entity then
				if e == PlayerEntity or e[Creature] ~= nil or e[Item] ~= nil then
					local challenge = World:FetchEntityById(entity[Platform].challenge)[MagicChallenge]
					challenge.difficulty = challenge.difficulty - 1

					if challenge.difficulty == 0 then 
						challenge.time = 0
					end
					
					PlayerEntity[Tension]:Down(challenge.difficulty)

					RemoveEntityFromDungeon(entity)
					World:Remove(entity)
				end
			end
		end
	end
end