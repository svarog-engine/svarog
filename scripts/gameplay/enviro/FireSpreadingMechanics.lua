local FireSpreadingMechanicsSystem = Engine.RegisterEnviroSystem("Fire Spreading")

function FireSpreadingMechanicsSystem:ShouldTick()
	return Dungeons.created and Dungeon.floor ~= nil
end

local directNeighbors = { { -1, 0 }, { 1, 0 }, { 0, 1 }, { 0, -1 } }
local diagonalNeighbors = { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }

function FireSpreadingMechanicsSystem:Tick()
	local remove = {}
	for _, entity in World:Exec(ECS.Query.All(Burning, Health, Position)):Iterator() do
		local burn, life, pos = entity[Burning], entity[Health], entity[Position]
		life.current = life.current - 1
		
		if life.current <= 0 then
			table.insert(remove, entity)
		end
	end

	for _, entity in ipairs(remove) do 
		local x, y = entity[Position].x, entity[Position].y
		RemoveEntityFromDungeon(entity)
		World:Remove(entity)
		Procgen.MakeObject("Cinders", x, y)
	end

	for _, entity in World:Exec(ECS.Query.All(Burning, Spread, Health, Position)):Iterator() do
		local burn, spread, life, pos = entity[Burning], entity[Spread], entity[Health], entity[Position]
		
		if life.current > 0 then
			spread.chance = spread.chance - 0.5
			for _, n in ipairs(directNeighbors) do
				local x, y = pos.x + n[1], pos.y + n[2]
				if Dungeon.floor:Has(x, y) then
					local tile = Dungeon.floor:Get(x, y)
					local c = math.floor(spread.chance)
					local ch = Chances[c]
					local yes = false
					if ch ~= nil then
						yes = Chances[c]:MakeGuess()
					end

					if yes then
						if tile.type == Floor then
							local id = Dungeon.floor:ID(x, y)
							local entities = Dungeon.entities[id] or {}
							local somethingLit = false
							local shouldStop = false

							for _, e in ipairs(entities) do
								if e[Unburnable] then 
									shouldStop = true 
									break
								end

								if not e[Burning] and e[Burnable] and not e[Unburnable] then
									e:Set(Burning{})
									somethingLit = true
								end
							end

							if not shouldStop then
								if not somethingLit and #entities == 0 then
									Procgen.MakeObject("Flame", x, y, life.current - 1, spread.chance)
								end
							end
						elseif tile.entity ~= nil and tile.entity[Burnable] and not tile.entity[Burning] then
							tile.entity:Unset(Burnable)
							if tile.entity[Health] == nil then
								local hp = math.min(life.current - 1, Dungeon.wallDistances:Get(x, y))
								tile.entity:Set(Health(Range(hp, hp)))
							end
							tile.entity:Set(Burning{}, Spread{ chance = spread.chance })
						end
					end
				end
			end
		end
	end
end