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
		if textComp ~= nil and who == PlayerEntity then
			if entity[Name].value == "Book" then
				Diary.Write("")
				Diary.Write("You open the book and read...")
			end
			Diary.Write("   \"" .. textComp.value .. "\"")
			shouldRemove = true
		elseif entity[BumpDiary] ~= nil and who == PlayerEntity then
			Diary.Write(entity[BumpDiary].text)
		elseif entity[CanMeltGold] ~= nil and who == PlayerEntity then
			local g = Contents.GetCount(who, "gold")
			if g < 1000 then
				Diary.Write("This could smelt a royal seal... Requires a lot of GOLD.")
			else
				Diary.Write("You put the gold into the cauldron... Now we wait.")
				Contents.Remove(who, "gold", g)
				entity:Set(SetTimer{ callback = function(e) 
					local x, y = entity[Position].x, entity[Position].y
					RemoveEntityFromDungeon(entity)
					World:Remove(entity)
					local s = Procgen.MakeObject("RoyalSeal", x, y)
				end }, Timeout{ value = 10 })
			end
		elseif entity[RoyalSeal] ~= nil and who == PlayerEntity then
				BoonWindow.seal = true
				BoonWindow.type = "Light"
				BoonWindow.onDone = function(bw)
					Seals = Seals + 1
					Diary.Write("You take hold of a goblin queen's ROYAL SEAL.")
					Diary.Write("Go forth and seal the hate...")
					entity:Unset(Bumped)
					RemoveEntityFromDungeon(entity)
					World:Remove(entity)
				end
				BoonWindow.open = true
				Input.Push("Boon")
		elseif entity[CanSeal] ~= nil and who == PlayerEntity then
			if Seals > 0 then
				Fade(entity, Colors.White, Colors.Black, 1)
				Diary.Write("You hold forth the ROYAL SEAL.")
				Diary.Write("The Sealing Stone recognizes your sacrifice.")
				Diary.Write("Know that you shall be remembered.")
			else
				Diary.Write("The cold stone doesn't budge.")
			end
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