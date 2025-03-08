local OpenCrateSystem = Engine.RegisterEnviroSystem("Open Crate")

function OpenCrateSystem:ShouldTick()
	return Dungeons.created
end

function OpenCrateSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Bumped, CanHaveContent)):Iterator() do
		local who = World:FetchEntityById(entity[Bumped].by)

		local shelveComp = entity[Shelve]
		if shelveComp ~= nil then
			Diary.Write(GetNextMessage())
			Diary.Write(" ")

			entity[Glyph].name =  entity[Glyph].name .. "_empty"
			entity:Unset(Shelve)
		end

		if who[Contents] ~= nil then
			if entity[Locked] ~= nil then 
				if who[Open] ~= nil then
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
					Contents.MoveItems(entity, who)
					entity:Unset(Contents)

					entity[Glyph].name =  entity[Glyph].name .. "_empty"
				end

				if who == PlayerEntity then 
					Diary.Write("You pick up stuff from the " .. entity[Name].value .. ".")
				end
			end
		end

		entity:Unset(Bumped)
	end
end