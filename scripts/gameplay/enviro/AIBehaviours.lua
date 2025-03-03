
local AIBehavioursSystem = Engine.RegisterEnviroSystem("AI Behaviours")

local function CheckMoveTowardsPlayer(entity)
	local ai = entity[AIMoveTowardsPlayer]
	if ai ~= nil then
		local pos = entity[Position]
		local current = Dungeon.playerDistance:Get(pos.x, pos.y)
		for _, neighbor in ipairs(Dungeon.playerDistance:Neighbors(pos.x, pos.y)) do
			if Dungeon.playerDistance:Has(neighbor.x, neighbor.y) then
				local value = Dungeon.playerDistance:Get(neighbor.x, neighbor.y)
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
		local current = Dungeon.playerDistance:Get(pos.x, pos.y)
		if current <= ai.distance then
			for _, neighbor in ipairs(Dungeon.playerDistance:Neighbors(pos.x, pos.y)) do
				if Dungeon.playerDistance:Has(neighbor.x, neighbor.y) then
					local value = Dungeon.playerDistance:Get(neighbor.x, neighbor.y)
					if value >= current and Rand:Range(0, 100) < ai.chance then
						table.insert(entity[Creature].goals, { "KeepDistanceFromPlayer", 1, function() PerformBump(entity, pos.x, pos.y, neighbor.x - pos.x, neighbor.y - pos.y) end })
					end
				end
			end
		end
	end
end

function AIBehavioursSystem:ShouldTick()
	return Dungeon.playerDistance ~= nil
end

function AIBehavioursSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Creature, Position)):Iterator() do
		entity[Creature].goals = {}
		CheckMoveTowardsPlayer(entity)
		CheckKeepDistanceFromPlayer(entity)
	end
end
