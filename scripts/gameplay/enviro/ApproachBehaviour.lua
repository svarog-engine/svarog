
local ApproachBehaviourSystem = Engine.RegisterEnviroSystem()

function ApproachBehaviourSystem:Update()
	StartMeasure()
	if Dungeon.created then
		for _, entity in World:Exec(ECS.Query.All(Creature, ApproachBehaviour, Position)):Iterator() do
			local approach = entity[ApproachBehaviour]
			local pos = entity[Position]
			local x, y = pos.x, pos.y

			local dist = Dungeon.playerDistance:Get(x, y)
			if dist ~= nil then 
				dist = dist.value
			
				local goals = {}
			
				for i = -1, 1 do
					if not (i == 0) then
						if Dungeon.playerDistance:Has(x + i, y) then
							local ndist = Dungeon.playerDistance:Get(x + i, y).value
							if ndist < dist then
								table.insert(goals, { x + i, y })
							end
						end

						if Dungeon.playerDistance:Has(x, y + i) then
							local ndist = Dungeon.playerDistance:Get(x, y + i).value
							if ndist < dist then
								table.insert(goals, { x, y + i })
							end
						end
					end
				end
			
				if #goals > 0 then
					print (#goals)
					local choice = goals[Rand:Range(1, #goals)]
					local dx = choice[1] - pos.x
					local dy = choice[2] - pos.y
					table.insert(entity[Creature].goals, { "Approach", 1, function() PerformBump(entity, pos.x, pos.y, dx, dy) end })
				end
			end
		end
	end
	EndMeasure("Approach")
end