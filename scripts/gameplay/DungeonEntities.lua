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

        if Dungeon.floor:Has(x, y) then
            local tile = Dungeon.floor:Get(x, y)
            if tile.entity == entity then 
                tile.type = Floor
                tile.entity = nil
            end

            print("REM", entity)
            World:Remove(entity)
        end
    end
end

function RemoveEntityFromDungeon(entity)
    RemoveEntity(entity[Position].x, entity[Position].y, entity)
end