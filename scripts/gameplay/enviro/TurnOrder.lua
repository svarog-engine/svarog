﻿
local TurnOrderSystem = Engine.RegisterEnviroSystem("Turn Order")

function TurnOrderSystem:ShouldTick()
	return Dungeons.created
end

function TurnOrderSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Creature)):Iterator() do
		local creature = entity[Creature]
			
		if #creature.goals > 0 then
			creature.actions = creature.actions + 1
			if creature.actions > 0 then
				local system, cost, action = table.unpack(creature.goals[Rand:Range(1, #creature.goals)])
				action()
				creature.actions = creature.actions - cost
			end
		end
	end
end