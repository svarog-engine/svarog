local PickUpMechanic = Engine.RegisterEnviroSystem()

function PickUpMechanic:Update()
	for _, entity in World:Exec(ECS.Query.All(Item, Bumped, Position)):Iterator() do
		local item = entity[Item]
		local pos = entity[Position]
		local who = World:FetchEntityById(entity[Bumped].by)

		if Dungeon.floor ~= nil then
			Dungeon.floor:Set(pos.x, pos.y, { type = Floor, pass = true })
		end

		if who[Inventory] ~= nil then
			Inventory.Add(who, item.name)
			Diary.Write("Item picked up.")
		end

		World:Remove(entity)
	end
end