
local TurnOrderSystem = Engine.RegisterEnviroSystem("Turn Order")

function TurnOrderSystem:ShouldTick()
	return Dungeons.created
end

function TurnOrderSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Creature)):Iterator() do
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
				local dx = Rand:Range(0, 2) - 1
				local dy = Rand:Range(0, 2) - 1
				if not (dx == 0 and dy == 0) then
					if Chances[5]:MakeGuess() then
						PerformBump(entity, pos.x, pos.y, pos.x + dx, pos.y + dy)
					end
				end
			end
		end
	end
end