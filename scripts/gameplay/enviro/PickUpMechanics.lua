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

		local shouldRemove = false

		local textComp = entity[Text]
		if textComp ~= nil then
			Diary.Write(textComp.text)
			Diary.Write(" ")
			shouldRemove = true

		elseif who[Contents] ~= nil and ItemLibrary[item.id] ~= nil then
			Contents.Add(who, item.id, item.quantity)

			if who == PlayerEntity then 
				Diary.Write("Picked up " .. ItemLibrary[item.id].name .. ".")
			end

			shouldRemove = true
		end

		if shouldRemove then
			RemoveEntityFromDungeon(entity)
			World:Remove(entity)
			Dungeon.passable:Set(pos.x, pos.y, true)
		else
			entity:Unset(Bumped)
		end
	end
end