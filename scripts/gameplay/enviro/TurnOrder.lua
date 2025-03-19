
local TurnOrderSystem = Engine.RegisterEnviroSystem("Turn Order")

function TurnOrderSystem:ShouldTick()
	return Dungeons.created
end

function TurnOrderSystem:Tick()
	local perfBump = PerformBump
	local ordered = {}
	for _, entity in World:Exec(ECS.Query.All(Creature)):Iterator() do
		if entity[Paralyzed] == nil then 
			local dist = Dungeon.playerDistance:Get(entity[Position].x, entity[Position].y)
			if ordered[dist] == nil then 
				ordered[dist] = {}
			end
			table.insert(ordered[dist], entity)
		end
	end
	
	for n = 1, 15 do
		if ordered[n] ~= nil then
			for _, entity in ipairs(ordered[n]) do
				local creature = entity[Creature]
				if entity[Health].current > 0 then
					if #creature.goals > 0 then
						creature.actions = creature.actions + 1
						if creature.actions > 0 then
							local system, cost, action = table.unpack(creature.goals[Rand:Range(1, #creature.goals)])
							action()
							creature.actions = creature.actions - cost
						end
					else
						local pos = entity[Position]
						local dx = Rand:Range(-1, 3)
						local dy = Rand:Range(-1, 3)
						if not (dx == 0 and dy == 0) then
							if Chances[5]:MakeGuess() then
								local mov = perfBump(entity, pos.x, pos.y, dx, dy)	
							end
						end
					end
				end
			end
		end
	end
end