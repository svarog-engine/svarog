
local ResolveMoveSystem = Engine.RegisterPlayerSystem()

function ResolveMoveSystem:Update()
	for _, entity in World:Exec(ECS.Query.All(Position, MoveTo)):Iterator() do
		entity[Position].x = entity[MoveTo].x
		entity[Position].y = entity[MoveTo].y
		Dungeon.dist = Dungeon.map:Dijkstra({ { entity[Position].x, entity[Position].y } }, 0, function(t) return t.pass end)
		entity:Unset(MoveTo)
	end
end