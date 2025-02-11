
local DoorMechanicsSystem = Engine.RegisterEnviroSystem()

function DoorMechanicsSystem:Update()
	StartMeasure()
	for _, entity in World:Exec(ECS.Query.All(Door, Position, Bumped)):Iterator() do
		local door = entity[Door]
		local key = entity[Key]
		local pos = entity[Position]
		local who = World:FetchEntityById(entity[Bumped].by)

		if door.locked then
			if key.item ~= nil  then
				if Inventory.HasItem(who, key.item) then 
					Inventory.Remove(who, key.item)
					door.locked = false
					door.closed = false

					entity[Glyph].name = "door_open"
					Fade(entity, Colors.Green, Colors.Black, 0.5)
					Diary.Write("Door unlocked")
				else
					Diary.Write("Key needed")
				end
			else
				Diary.Write("The door is locked.")
				entity[Glyph].name = "door_locked"
				Fade(entity, Colors.Black, Colors.Red, 0.5)
			end
		elseif door.closed then
			Diary.Write("You open the door.")
			door.closed = false
			entity[Glyph].name = "door_open"
			Fade(entity, Colors.Green, Colors.Black, 0.5)
		else
			if door.travelTo ~= nil then
				for i = 1, Config.Width do
					for j = 1, Config.Height do
						Engine.Glyph(i, j, "empty")
					end
				end
				local oldRoom = Dungeon.index
				MakeDungeonRoom(door.travelTo)
				local door = FindDoorTo(oldRoom)
				if door ~= nil then
					door[Door].closed = false
					door[Door].locked = false
					door[Door].hidden = false
					door[Glyph].name = "door_open"
					local x, y = door[Position].x, door[Position].y
					PlayerEntity[Position].x = x
					PlayerEntity[Position].y = y
				end
			end
		end
		entity:Unset(Bumped)
	end
	EndMeasure("Doors")
end
