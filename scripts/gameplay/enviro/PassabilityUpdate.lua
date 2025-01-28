
local PassabilityUpdateSystem = Engine.RegisterEnviroSystem()

function PassabilityUpdateSystem:Update()
	if Dungeon.created and PlayerEntity ~= nil then
		for _, k in Dungeon.floor:Iterate() do
			local tile = Dungeon.floor.tiles[k]
			local x, y = tile.x, tile.y
			tile = tile.value

			if tile.type == Floor then
				Dungeon.passable:Set(x, y, true)
			elseif tile.type == Door then
				Dungeon.passable:Set(x, y, not tile.entity[Door].closed)
			end
		end

		Dungeon.passable:Set(PlayerEntity[Position].x, PlayerEntity[Position].y, false)
		
		for _, entity in World:Exec(ECS.Query.All(Creature, Position).None(Friendly)):Iterator() do
			Dungeon.passable:Set(entity[Position].x, entity[Position].y, false)
		end
	end
end
