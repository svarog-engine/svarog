
local PassabilityUpdateSystem = Engine.RegisterEnviroSystem()

function PassabilityUpdateSystem:Update()
	StartMeasure()
	if Dungeons.created and PlayerEntity ~= nil then
		local w, h = Dungeon.floor:Size()
		for x = 1, w do 
			for y = 1, h do
				if Dungeon.floor:Has(x, y) then
					local tile = Dungeon.floor.tiles[x][y]
					if tile.type == Floor then
						Dungeon.passable:Set(x, y, true)
					elseif tile.type == Door then
						Dungeon.passable:Set(x, y, not tile.entity[Door].closed)
					end
				end
			end
		end

		Dungeon.entities = {}

		AddEntityToDungeon(PlayerEntity[Position].x, PlayerEntity[Position].y, PlayerEntity)
		
		for _, entity in World:Exec(ECS.Query.All(Creature, Position)):Iterator() do
			AddEntityToDungeon(entity[Position].x, entity[Position].y, entity)
		end

		for _, entity in World:Exec(ECS.Query.All(Item, Position)):Iterator() do
			AddEntityToDungeon(entity[Position].x, entity[Position].y, entity)
		end
	end
	EndMeasure("Passability")
end
