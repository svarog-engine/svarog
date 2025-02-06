
local DoorMechanicsSystem = Engine.RegisterEnviroSystem()

function DoorMechanicsSystem:Update()
	StartMeasure()
	for _, entity in World:Exec(ECS.Query.All(Door, Position, Bumped)):Iterator() do
		local door = entity[Door]
		local key = entity[Key]
		local pos = entity[Position]
		print (entity[Bumped], entity[Bumped].by)
		local who = World:FetchEntityById(entity[Bumped].by)

		if door.locked then
			if key.item ~= nil  then
				if Inventory.HasItem(who, key.item) then 
					Inventory.Remove(who, key.item)
					door.locked = false
					door.closed = false

					entity[Glyph].name = "door_open"
					Fade(entity, Colors.Green, Colors.Black)
					Diary.Write("Door unlocked")
				else
					Diary.Write("Key needed")
				end
			else
				Diary.Write("The door is locked.")
				Fade(entity, Colors.Red, Colors.Black)
			end
		elseif door.closed then
			Diary.Write("You open the door.")
			door.closed = false
			entity[Glyph].name = "door_open"
			Fade(entity, Colors.Green, Colors.Black)
		end
		entity:Unset(Bumped)
	end
	EndMeasure("Doors")
end
