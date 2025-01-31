
local TurnOrderSystem = Engine.RegisterEnviroSystem()

function TurnOrderSystem:Update()
	StartMeasure()
	if Dungeon.created then
		for _, entity in World:Exec(ECS.Query.All(Creature)):Iterator() do
			local creature = entity[Creature]
			
			if #creature.goals > 0 then
				creature.actions = creature.actions + 1
				if creature.actions > 0 then
					local system, cost, action = table.unpack(creature.goals[Rand:Range(1, #creature.goals)])
					--print(creature.name, system, cost)
					action()
					creature.actions = creature.actions - cost
				end
			end
		end
	end
	EndMeasure("TurnOrder")
end