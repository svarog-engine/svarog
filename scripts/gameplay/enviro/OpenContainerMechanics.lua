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
				if Contents.HasItem(who, "key") then 
					Contents.Remove(who, "key")
					entity:Unset(Locked)
				else
					if who == playerEntity then 
						Diary.Write("mika")
					end
				end
			end

			if entity[Locked] == nil then
				if entity[Contents] ~= nil then
					Contents.MoveItems(entity, who)
					entity:Unset(Contents)

					entity[Glyph].name =  entity[Glyph].name .. "_empty"
				end

				if who == playerEntity then 
					Diary.Write("mika")
				end
			end
		end

		entity:Unset(Bumped)
	end
end