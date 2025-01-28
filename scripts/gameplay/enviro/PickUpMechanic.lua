local PickUpMechanic = Engine.RegisterEnviroSystem()

function PickUpMechanic:Update()
	for _, entity in World:Exec(ECS.Query.All(Item, Bumped, Position)):Iterator() do
		local item = entity[Item]
		local pos = entity[Position]

		Diary.Write("Item picked up.")

		if Dungeon.map ~= nil then
			Dungeon.map:Set(pos.x, pos.y, { type = Floor, pass = true })
		end

		Inventory.Add(item.name)

		World:Remove(entity)
	end
end