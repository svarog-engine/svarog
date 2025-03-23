local OpenCrateSystem = Engine.RegisterEnviroSystem("Open Crate")

function OpenCrateSystem:ShouldTick()
	return Dungeons.created
end

function OpenCrateSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Bumped, CanHaveContent)):Iterator() do
		local who = World:FetchEntityById(entity[Bumped].by)

		local shelveComp = entity[Shelve]
		if shelveComp ~= nil and who == PlayerEntity then
			if Chances[5]:MakeGuess() then
				Diary.Write(" ")
				Diary.Write("You learn:")
				Diary.Write("  " .. GetNextMessage())
				Diary.Write(" ")
			else
				Diary.Write(" ")
				Diary.Write("You find... " .. BookNames[Rand:Range(1, #BookNames)] .. " by " .. Goblins[Rand:Range(1, #Goblins)] .. ", " .. Attr[Rand:Range(1, #Attr)] .. " " .. Jobs[Rand:Range(1, #Jobs)])
				Diary.Write(" ")
				Diary.Write(" ")
			end
			entity[Glyph].name = entity[Glyph].name .. "_empty"
			entity:Unset(Shelve)
		elseif who[Contents] ~= nil then
			if entity[Locked] ~= nil then 
				if who[Silenced] == nil and who[Open] ~= nil then
					Contents.Remove(who, "key")
					entity:Unset(Locked)
					
					if who == PlayerEntity then 
						Diary.Write("The " .. entity[Name].value .. " unlocks. Your [OPEN] glyph quivers.")
						who[Tension]:Up(1)
					end
				elseif Contents.HasItem(who, "key") then 
					Contents.Remove(who, "key")
					entity:Unset(Locked)
					
					if who == PlayerEntity then 
						Diary.Write("You use a key to unlock the " .. entity[Name].value .. ".")
					end
				else
					if who == PlayerEntity then 
						Diary.Write("You don't have the right key for this " .. entity[Name].value .. ".")
					end
				end
			else
				if entity[Contents] ~= nil then
					if who ~= PlayerEntity then
						local moved, total = Contents.MoveItems(entity, who)
						if #moved == total then
							entity:Unset(Contents)
							entity[Glyph].name =  entity[Glyph].name .. "_empty"
						end
					else
						if #entity[Contents].items == 0 then
							entity:Unset(Contents)
							entity[Glyph].name = entity[Glyph].name .. "_empty"
						else
							LootTable[LootInventory].target = entity
							Input.Push("Loot")
						end
					end
				end
			end
		end

		entity:Unset(Bumped)
	end
end