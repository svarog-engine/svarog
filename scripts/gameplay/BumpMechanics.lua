
-- return true if moved
function PerformBump(entity, x, y, dx, dy)
	local nx = x + dx
	local ny = y + dy
	local pass = Dungeon.passable:Has(nx, ny) and Dungeon.passable:Get(nx, ny)
	local id = Dungeon.floor:ID(nx, ny)
	local entities = Dungeon.entities[id] or {}

	local somethingElse = false	
	for _, e in ipairs(entities) do
		if e ~= entity then
			somethingElse = true
			break
		end
	end

	if somethingElse then
		for _, e in ipairs(entities) do
			if e ~= entity then
				e:Set(Bumped({ by = entity.id }))
				Fade(e, Colors.Yellow, Colors.Black, 0.5)
				print((entity[Name].value or "???") .. " (" .. (entity[ID] or {}).value .. ") bumped into " .. (e[Name].value or "???") .. " (" .. ((e[ID] or {}).value or "?") .. ")")
				return true
			end
		end
	elseif pass then
		if entity[Position] ~= nil then
			RemoveEntityFromDungeon(entity)
			entity[Position].x = nx
			entity[Position].y = ny
			AddEntityToDungeon(nx, ny, entity)
			return true
		end
	elseif Dungeon.floor:Has(nx, ny) and Dungeon.floor.tiles[nx][ny].entity ~= nil then
		local e = Dungeon.floor.tiles[nx][ny].entity
		Dungeon.floor:Get(nx, ny).entity:Set(Bumped({ by = entity.id }))
		Fade(Dungeon.floor:Get(nx, ny).entity, Colors.Green, Colors.Black, 0.5)
	end

	return false
end