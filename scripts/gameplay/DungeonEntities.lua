
SetDressing = {}

function AddEntityToDungeon(x, y, entity)
	if Dungeon == nil then
		Svarog.Instance:LogError("Adding failed: Dungeon nil")
		return nil
	end

	if Dungeon.floor ~= nil then
		local id = Dungeon.floor:ID(x, y)
		if Dungeon.entities[id] == nil then
			Dungeon.entities[id] = {}
		end

		table.insert(Dungeon.entities[id], entity)
		table.insert(Dungeon.entitiesList, entity)
		return entity
	else
		Svarog.Instance:LogError("Adding failed: no floor")
		return nil
	end
end

local function RemoveEntity(x, y, entity)
	if Dungeon.floor ~= nil then
		local id = Dungeon.floor:ID(x, y)
		if Dungeon.entities[id] ~= nil then
			for i, e in ipairs(Dungeon.entities[id]) do
				if e == entity then
					table.remove(Dungeon.entities[id], i)
					break
				end
			end

			for i, e in ipairs(Dungeon.entitiesList) do
				if e == entity then
					table.remove(Dungeon.entitiesList, i)
					break
				end
			end
		end	
	end

	for i, e in ipairs(SetDressing) do
		if e == entity then
			table.remove(SetDressing, i)
			local x, y = e[Position].x, e[Position].y
			local tile = Dungeon.floor:Get(x, y)
			if tile.entity == entity then 
				tile.entity = nil
				tile.type = Floor
			end
			Dungeon.passable:Set(x, y, true)
			Dungeon.memory:Set(x, y, true)
			break
		end
	end
end

function RemoveEntityFromDungeon(entity)
	if entity[Position] ~= nil then
		RemoveEntity(entity[Position].x, entity[Position].y, entity)
	end
end
