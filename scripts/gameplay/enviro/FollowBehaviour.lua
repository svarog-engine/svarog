
local FollowBehaviourSystem = Engine.RegisterEnviroSystem()

function FollowBehaviourSystem:Update()
	if Dungeon.created then
		for _, entity in World:Exec(ECS.Query.All(Creature, FollowBehaviour, Position)):Iterator() do
			local follow = entity[FollowBehaviour]
			local pos = entity[Position]
			local x, y = pos.x, pos.y

			local dist = Dungeon.playerDistance:MinAround(x, y)
			
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
						local ndist = math.floor(Dungeon.playerDistance:MinAround(x + i, y))
						if predicate(ndist, dist) then
							table.insert(goals, { x + i, y })
						end
					end

					if Dungeon.playerDistance:Has(x, y + i) then
						local ndist = math.floor(Dungeon.playerDistance:MinAround(x, y + i))
						if predicate(ndist, dist) then
							table.insert(goals, { x, y + i })
						end
					end
				end
			end
			
			if #goals > 0 then
				local choice = goals[Rand:Range(1, #goals)]
				pos.x = choice[1]
				pos.y = choice[2]
			end
		end
	end
end