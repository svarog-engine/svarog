
local HoldDistanceBehaviourSystem = Engine.RegisterEnviroSystem()

function HoldDistanceBehaviourSystem:Update()
	StartMeasure()
	if Dungeon.created then
		for _, entity in World:Exec(ECS.Query.All(Creature, HoldDistanceBehaviour, Position)):Iterator() do
			local follow = entity[HoldDistanceBehaviour]
			local pos = entity[Position]
			local x, y = pos.x, pos.y

			local dist = Dungeon.playerDistance:Get(x, y)
			if dist ~= nil then
				dist = dist.value
			
				local goals = {}
				local predicate = function(a, b) return a <= b end 
				if dist < follow.distance then
					predicate = function(a, b) return a >= b end
				elseif dist == follow.distance then
					predicate = function(a, b) return math.abs(a - b) <= 1 end
				end

				for i = -1, 1 do
					if not (i == 0) then
						if Dungeon.playerDistance:Has(x + i, y) then
							local ndist = math.floor(Dungeon.playerDistance:Get(x + i, y).value)
							if predicate(ndist, dist) then
								table.insert(goals, { x + i, y })
							end
						end

						if Dungeon.playerDistance:Has(x, y + i) then
							local ndist = math.floor(Dungeon.playerDistance:Get(x, y + i).value)
							if predicate(ndist, dist) then
								table.insert(goals, { x, y + i })
							end
						end
					end
				end
			
				if #goals > 0 then
					local choice = goals[Rand:Range(1, #goals)]
					local dx = choice[1] - pos.x
					local dy = choice[2] - pos.y
					PerformBump(entity, pos.x, pos.y, dx, dy)
				end
			end
		end
	end
	EndMeasure("HoldDistance")
end