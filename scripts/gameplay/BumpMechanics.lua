
function PerformBump(entity, x, y, dx, dy)
	local nx = x + dx
	local ny = y + dy
			
	local pass = Dungeon.passable:Has(nx, ny) and Dungeon.passable:Get(nx, ny)
	local id = Dungeon.floor:ID(nx, ny)
	local entities = Dungeon.entities[id] or {}
	if #entities > 0 then
		for _, e in ipairs(entities) do
			e:Set(Bumped({ by = entity.id }))
		end
	elseif pass then
		if entity[Position] ~= nil then
			RemoveEntityFromDungeon(entity)
			entity[Position].x = nx
			entity[Position].y = ny
			AddEntityToDungeon(nx, ny, entity)
		end
	elseif Dungeon.floor:Has(nx, ny) and Dungeon.floor.tiles[nx][ny].entity ~= nil then
		Dungeon.floor:Get(nx, ny).entity:Set(Bumped({ by = entity.id }))
	end
end