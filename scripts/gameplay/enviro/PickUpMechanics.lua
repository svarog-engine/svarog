local PickUpMechanicsSystem = Engine.RegisterEnviroSystem("Pickup")

function PickUpMechanicsSystem:ShouldTick()
	return Dungeons.created
end

function PickUpMechanicsSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Item, Bumped, Position)):Iterator() do
		local item = entity[Item]
		local pos = entity[Position]
		local who = World:FetchEntityById(entity[Bumped].by)

		if who == nil then
			return
		end

		if who[Contents] ~= nil and ItemLibrary[item.id] ~= nil then
			Contents.Add(who, item.id, item.quantity)

			RemoveEntityFromDungeon(entity)
			World:Remove(entity)
			Dungeon.passable:Set(pos.x, pos.y, true)

			if who == PlayerEntity then 
				Diary.Write("Picked up " .. ItemLibrary[item.id].name .. ".")
			end
		else
			entity:Unset(Bumped)
		end
	end
end