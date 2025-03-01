
Player = ECS.Component()
Friendly = ECS.Component()
Creature = ECS.Component{ name = "", goals = {}, actions = 0, timestamp = 0 }

function TickCreature(entity)
	if Engine.Tick() > entity[Creature].timestamp then
		entity[Creature].timestamp = entity[Creature].timestamp + 1
		entity[Creature].goals = {}
	end
end

Item = ECS.Component{id = ""}

Bump = ECS.Component{ x = 0, y = 0, dx = 0, dy = 0 }
Bumped = ECS.Component{ by = 0 }

Floor = ECS.Component()
Wall = ECS.Component()
Door = ECS.Component{ closed = true, locked = false, travelTo = nil, hidden = false }
Key = ECS.Component { item = nil }
