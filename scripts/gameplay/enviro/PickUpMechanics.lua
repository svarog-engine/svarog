local PickUpMechanicsSystem = Engine.RegisterEnviroSystem("Pickup")

function PickUpMechanicsSystem:ShouldTick()
	return Dungeons.created
end

function PickUpMechanicsSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Item, Bumped, Position)):Iterator() do
		local item = entity[Item]
		local pos = entity[Position]
		local who = World:FetchEntityById(entity[Bumped].by)

		print(item, pos, who == PlayerEntity)

		if who[Contents] ~= nil then
			print(item.id, ItemLibrary)
			table.insert(who[Contents].items, item.id)
			Diary.Write("Picked up " .. ItemLibrary[item.id].name .. ".")
			World:Remove(entity)
		else
			entity:Unset(Bumped)
		end
	end
end