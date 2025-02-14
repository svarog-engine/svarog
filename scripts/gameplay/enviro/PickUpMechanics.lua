local PickUpMechanicsSystem = Engine.RegisterEnviroSystem()

function PickUpMechanicsSystem:Update()
	StartMeasure()
	for _, entity in World:Exec(ECS.Query.All(Item, Bumped, Position)):Iterator() do
		local item = entity[Item]
		local pos = entity[Position]
		local who = World:FetchEntityById(entity[Bumped].by)

		if who[Inventory] ~= nil then
			Inventory.Add(who, item.id)
			Diary.Write("Picked up " .. ItemLibrary[item.id].name .. ".")
			World:Remove(entity)
		else
			entity:Unset(Bumped)
		end
	end
	EndMeasure("PickUp")
end