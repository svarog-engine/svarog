
local AIBehavioursSystem = Engine.RegisterEnviroSystem("AI Behaviours")

local function CheckMoveTowardsPlayer(entity)
	local ai = entity[AIMoveTowardsPlayer]
	if ai ~= nil then
		local pos = entity[Position]
		local current = Dungeon.playerDistance:Get(pos.x, pos.y)
		local neighbors = Dungeon.playerDistance:Neighbors(pos.x, pos.y)
		for _, neighbor in ipairs(neighbors) do
			if Dungeon.playerDistance:Has(neighbor.x, neighbor.y) then
				local value = Dungeon.playerDistance:Get(neighbor.x, neighbor.y)
				if value < current and Chances[ai.chance]:MakeGuess() then
					table.insert(entity[Creature].goals, { "MoveTowardsPlayer", 1, function() PerformBump(entity, pos.x, pos.y, neighbor.x - pos.x, neighbor.y - pos.y) end })
				end
			end
		end
		if #entity[Creature].goals == 0 then
			for _, neighbor in ipairs(neighbors) do
				if Dungeon.playerDistance:Has(neighbor.x, neighbor.y) then
					local value = Dungeon.playerDistance:Get(neighbor.x, neighbor.y)
					if value <= current and Chances[ai.chance]:MakeGuess() then
						table.insert(entity[Creature].goals, { "MoveTowardsPlayer", 1, function() PerformBump(entity, pos.x, pos.y, neighbor.x - pos.x, neighbor.y - pos.y) end })
					end
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
					if value >= current and Chances[ai.chance]:MakeGuess() then
						table.insert(entity[Creature].goals, { "KeepDistanceFromPlayer", 1, function() PerformBump(entity, pos.x, pos.y, neighbor.x - pos.x, neighbor.y - pos.y) end })
					end
				end
			end
		end
	end
end

function AIBehavioursSystem:ShouldTick()
	return Dungeon ~= nil and Dungeon.playerDistance ~= nil
end

function AIBehavioursSystem:Tick()
	local p = PlayerEntity[Position]
	local px, py = p.x, p.y
	for _, entity in World:Exec(ECS.Query.All(Creature, Position)):Iterator() do
		local pos = entity[Position]
		local ex, ey = pos.x, pos.y
		entity[Creature].goals = {}
		if Dungeon.playerDistance:Get(ex, ey) < 9 then
			CheckMoveTowardsPlayer(entity)
			CheckKeepDistanceFromPlayer(entity)
		end
	end
end
