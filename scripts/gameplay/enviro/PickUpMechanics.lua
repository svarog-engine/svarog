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
			if entity[Name].value == "Book" then
				Diary.Write("")
				Diary.Write("You open the book and read...")
			end
			Diary.Write("   \"" .. textComp.value .. "\"")
			shouldRemove = true

		elseif who[Contents] ~= nil and ItemLibrary[item.id] ~= nil then
			if Contents.HasSpace(who, item.id) then
				Contents.Add(who, item.id, item.quantity)

				if who == PlayerEntity then 
					Diary.Write("Picked up " .. ItemLibrary[item.id].name .. ".")
				end

				shouldRemove = true
			else
				if who == PlayerEntity then
					Diary.Write("Can't pick up " .. ItemLibrary[item.id].name .. ".")
				end

				Fade(who, Colors.Red, Colors.Black, 0.2)

				entity:Unset(FadeOut)

				local whoPosition = who[Position]
				RemoveEntityFromDungeon(who)

				whoPosition.x = pos.x
				whoPosition.y = pos.y

				AddEntityToDungeon(pos.x, pos.y, who)
			end
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