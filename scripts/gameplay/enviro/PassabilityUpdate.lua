
local PassabilityUpdateSystem = Engine.RegisterEnviroSystem()

local function AddEntity(x, y, entity)
	local id = Dungeon.floor:ID(x, y)
	if Dungeon.entities[id] == nil then
		Dungeon.entities[id] = {}
	end

	table.insert(Dungeon.entities[id], entity)
end

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

		Dungeon.entities = {}

		AddEntity(PlayerEntity[Position].x, PlayerEntity[Position].y, PlayerEntity)
		
		for _, entity in World:Exec(ECS.Query.All(Creature, Position)):Iterator() do
			AddEntity(entity[Position].x, entity[Position].y, entity)
		end

		for _, entity in World:Exec(ECS.Query.All(Item, Position)):Iterator() do
			AddEntity(entity[Position].x, entity[Position].y, entity)
		end
	end
end
