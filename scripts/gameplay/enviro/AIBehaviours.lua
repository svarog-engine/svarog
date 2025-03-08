
local AIBehavioursSystem = Engine.RegisterEnviroSystem("AI Behaviours")

local function Distance(x1, y1, x2, y2)
	local dx, dy = x1 - x2, y1 - y2
	return math.sqrt(dx * dx + dy * dy)
end

local function CheckAIRest(entity)
	local ai = entity[AIRest]
	if ai ~= nil then
		if Chances[ai.chance]:MakeGuess() then
			table.insert(entity[Creature].goals, { "Rest", 1, function() end })
		end
	end
end

local function CheckBreakThroughToPlayer(entity)
	local ai = entity[AIBreakThroughToPlayer]
	if ai ~= nil then
		local px, py = PlayerEntity[Position].x, PlayerEntity[Position].y
		local ex, ey = entity[Position].x, entity[Position].y

		if Chances[ai.chance]:MakeGuess() then
			local pd, bx, by = Distance(px, py, ex, ey), ex, ey
			if pd <= ai.distance then
				table.insert(entity[Creature].goals, { "Breakthrough", 1, function()
					local pts = Geometry:Boundary(Geometry:MakeLine(px, py, ex, ey)).Points:GetEnumerator()
					while pts:MoveNext() do
						local pt = pts:Current()
						if Dungeon.floor:Get(pt.X, pt.Y).type == Wall then
							Dungeon.floor:Get(pt.X, pt.Y).type = Floor
							local dust = Procgen.MakeObject("dust", pt.X, pt.Y)
							Fade(dust, Colors.White, Colors.DarkGray, 0.33 * (Rand:F01() + 0.5))
						end
						local d = Distance(px, py, pt.X, ptY)
						if d > 0 and d < pd then
							pd = d
							bx = pt.X
							by = pt.Y
						end
					end
				end })
			end
		end
	end
end

local function CheckAttackIfStandingNextTo(entity)
	local ai = entity[AIAttackIfStandingNextTo]
	if ai ~= nil then
		local pos = entity[Position]
		local current = Dungeon.playerDistance:Get(pos.x, pos.y)
		if current == 1 then
			table.insert(entity[Creature].goals, { "AttackIfStandingNextTo", 1, function() PerformBump(entity, pos.x, pos.y, PlayerEntity[Position].x - pos.x, PlayerEntity[Position].y - pos.y) end })
		end
	end
end

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

local function CheckRandomWalk(entity)
	local pos = entity[Position]
	local dx = Rand:Range(-1, 1)
	local dy = Rand:Range(-1, 1)
	if not (dx == 0 and dy == 0) then
		table.insert(entity[Creature].goals, { "Random Walk", 1, function() PerformBump(entity, pos.x, pos.y, pos.x + dx, pos.y + dy) end })
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
		local sight = entity[Sight]
		
		if sight == nil then 
			sight = 4 
		else
			sight = sight.radius
		end

		local ex, ey = pos.x, pos.y
		entity[Creature].goals = {}
		
		if entity[Calm] ~= nil then
			if Chances[entity[Calm].chance]:MakeGuess() then
				CheckAIRest(entity)
				CheckAIRest(entity)
				CheckAIRest(entity)
			end
		end

		if entity[Darken] ~= nil then
			sight = 0
		end

		if Dungeon.playerDistance:Get(ex, ey) < sight then
			CheckMoveTowardsPlayer(entity)
			CheckKeepDistanceFromPlayer(entity)
			CheckAIRest(entity)
			CheckAttackIfStandingNextTo(entity)
			CheckBreakThroughToPlayer(entity)
			CheckRandomWalk(entity)
		else
			CheckAIRest(entity)
			CheckRandomWalk(entity)
		end
	end
end
