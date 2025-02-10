
local AIBehavioursSystem = Engine.RegisterEnviroSystem()

local function CheckMoveTowardsPlayer(entity)
	local ai = entity[AIMoveTowardsPlayer]
	if ai ~= nil then
		local pos = entity[Position]
		local current = Dungeons.playerDistance:Get(pos.x, pos.y)
		for _, neighbor in ipairs(Dungeons.playerDistance:Neighbors(pos.x, pos.y)) do
			if Dungeons.playerDistance:Has(neighbor.x, neighbor.y) then
				local value = Dungeons.playerDistance:Get(neighbor.x, neighbor.y)
				if value < current and Rand:Range(0, 100) < ai.chance then
					table.insert(entity[Creature].goals, { "MoveTowardsPlayer", 1, function() PerformBump(entity, pos.x, pos.y, neighbor.x - pos.x, neighbor.y - pos.y) end })
				end
			end
		end
	end
end

local function CheckKeepDistanceFromPlayer(entity)
	local ai = entity[KeepDistanceFromPlayer]
	if ai ~= nil then
		local pos = entity[Position]
		local current = Dungeons.playerDistance:Get(pos.x, pos.y)
		if current <= ai.distance then
			for _, neighbor in ipairs(Dungeons.playerDistance:Neighbors(pos.x, pos.y)) do
				if Dungeons.playerDistance:Has(neighbor.x, neighbor.y) then
					local value = Dungeons.playerDistance:Get(neighbor.x, neighbor.y)
					if value >= current and Rand:Range(0, 100) < ai.chance then
						table.insert(entity[Creature].goals, { "KeepDistanceFromPlayer", 1, function() PerformBump(entity, pos.x, pos.y, neighbor.x - pos.x, neighbor.y - pos.y) end })
					end
				end
			end
		end
	end
end

function AIBehavioursSystem:Update()
	StartMeasure()
	for _, entity in World:Exec(ECS.Query.All(Creature, Position)):Iterator() do
		entity[Creature].goals = {}
		CheckMoveTowardsPlayer(entity)
		CheckKeepDistanceFromPlayer(entity)
	end
	EndMeasure("AI Behaviours")
end
