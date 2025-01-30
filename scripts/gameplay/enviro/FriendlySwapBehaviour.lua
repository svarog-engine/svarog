
local FriendlySwapBehaviourSystem = Engine.RegisterEnviroSystem()

function FriendlySwapBehaviourSystem:Update()
	StartMeasure()
	if Dungeon.created then
		for _, friend in World:Exec(ECS.Query.All(Creature, Friendly, Bumped, Position)):Iterator() do
			local x, y = friend[Position].x, friend[Position].y
			local who = World:FetchEntityById(friend[Bumped].by)

			if who[Player] ~= nil then
				RemoveEntityFromDungeon(friend)
				friend[Position].x = who[Position].x
				friend[Position].y = who[Position].y
				AddEntityToDungeon(friend[Position].x, friend[Position].y, friend)

				RemoveEntityFromDungeon(who)
				who[Position].x = x
				who[Position].y = y
				AddEntityToDungeon(x, y, who)

				friend:Unset(Bumped)
				friend[Creature].actions = -1
			end
		end
	end

	EndMeasure("FriendlySwap")
end