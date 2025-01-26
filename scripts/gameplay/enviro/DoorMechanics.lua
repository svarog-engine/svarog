
local DoorMechanicsSystem = Engine.RegisterEnviroSystem()

function DoorMechanicsSystem:Update()
	for _, entity in World:Exec(ECS.Query.All(Door, Position, Bumped)):Iterator() do
		local door = entity[Door]
		local pos = entity[Position]
		local who = World:FetchEntityById(entity[Bumped].by)

		if door.locked then
			Diary.Write("The door is locked.")
			Fade(entity, Colors.Red, Colors.Black)
			-- unlock logic here
		elseif door.closed then
			Diary.Write("You open the door.")
			door.closed = false
			entity[Glyph].name = "door_open"
			Fade(entity, Colors.Green, Colors.Black)
			DungeonEntity[Dungeon].map:Get(pos.x, pos.y).value.pass = true
		end
		entity:Unset(Bumped)
	end
end
