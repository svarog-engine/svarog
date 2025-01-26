
local FollowBehaviourSystem = Engine.RegisterEnviroSystem()

function FollowBehaviourSystem:Update()
	print("FollowBehaviourSystem")
	if Dungeon.playerDistance ~= nil then
		for _, entity in World:Exec(ECS.Query.All(Creature, FollowBehaviour, Position)):Iterator() do
			local follow = entity[FollowBehaviour]
			local pos = entity[Position]
			local x, y = pos.x, pos.y
			local dist = Dungeon.playerDistance:Get(x, y).value
			print("Distance: " .. dist)
			local goals = {}
			if dist > follow.distance then
				print("Follower too far!")
				for i = -1, 1 do
					if not (i == 0) then
						if Dungeon.playerDistance:Has(x + i, y) then
							local ndist = math.floor(Dungeon.playerDistance:Get(x + i, y).value)
							if ndist < dist then
								table.insert(goals, { x + i, y })
								table.insert(goals, { x + i, y })
								table.insert(goals, { x + i, y })
							elseif ndist == dist then
								table.insert(goals, { x + i, y })
							end
						end

						if Dungeon.playerDistance:Has(x, y + i) then
							local ndist = math.floor(Dungeon.playerDistance:Get(x, y + i).value)
							if ndist < dist then
								table.insert(goals, { x, y + i })
								table.insert(goals, { x, y + i })
								table.insert(goals, { x, y + i })
							elseif ndist == dist then
								table.insert(goals, { x, y + i })
							end
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