local PickUpMechanic = Engine.RegisterEnviroSystem()

function PickUpMechanic:Update()
	StartMeasure()
	if Dungeon.created then
		for _, entity in World:Exec(ECS.Query.All(Item, Bumped, Position)):Iterator() do
			local item = entity[Item]
			local pos = entity[Position]
			local who = World:FetchEntityById(entity[Bumped].by)

			if who[Inventory] ~= nil then
				Inventory.Add(who, item.name)
				Diary.Write("Picked up " .. item.name .. ".")
				World:Remove(entity)
			else
				entity:Unset(Bumped)
			end
		end
	end
	EndMeasure("PickUp")
end