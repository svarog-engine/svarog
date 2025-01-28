
local ResolveMoveSystem = Engine.RegisterPlayerSystem()

function ResolveMoveSystem:Update()
	for _, entity in World:Exec(ECS.Query.All(Position, MoveTo)):Iterator() do
		entity[Position].x = entity[MoveTo].x
		entity[Position].y = entity[MoveTo].y
		
		entity:Unset(MoveTo)
	end
end