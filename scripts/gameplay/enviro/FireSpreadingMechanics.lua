local FireSpreadingMechanicsSystem = Engine.RegisterEnviroSystem("Fire Spreading")

function FireSpreadingMechanicsSystem:ShouldTick()
	return Dungeons.created and Dungeon.floor ~= nil
end

local floor = math.floor
local min = math.min

local directNeighbors = { { -1, 0 }, { 1, 0 }, { 0, 1 }, { 0, -1 } }
local diagonalNeighbors = { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }

function FireSpreadingMechanicsSystem:Tick()
	local remove = {}
	for _, entity in World:Exec(ECS.Query.All(Burning, Health, Position)):Iterator() do
		local burn, life, pos = entity[Burning], entity[Health], entity[Position]
		
		local isPlayer = entity == PlayerEntity
		local chance = 2
		--local usedCalm = false
		local usedLuck = false
		if isPlayer then
			--if entity[Calm] ~= nil then
			--	chance = entity[Calm].level + chance
			--	usedCalm = true
			--end

			if entity[Luck] ~= nil then
				chance = entity[Luck].level * 3 + chance
				usedLuck = true
			end
		end
		if Chances[chance]:MakeGuess() or PlayerEntity[Light] ~= nil then
			entity:Unset(Burning)
			if isPlayer then
				if usedLuck then
					Diary.Write("The fire dissipates. Your [LUCK] glyph quivers.")
				elseif PlayerEntity[Light] ~= nil then
					Diary.Write("You are light, fire walks with you.")
				end
			end
		else
			life.current = life.current - 1
		
			if life.current <= 0 then
				table.insert(remove, entity)
			end
		end
	end

	for _, entity in ipairs(remove) do
		local x, y = entity[Position].x, entity[Position].y
		local contents = entity[Contents]
		local hasDrop = false
		if contents ~= nil then 
			hasDrop = #contents.items
			Contents.DropAll(entity, x, y)
		end

		if entity == PlayerEntity then
			PlayerEntity:Set(Death{ reason = "Burnt to a crisp in a fire" })
			Input.Push("Death")
			return
		end

		RemoveEntityFromDungeon(entity)
		World:Remove(entity)

		if not hasDrop then 
			Dungeon.passable:Set(x, y, true)
			Procgen.MakeObject("Cinders", x, y)
		end
	end

	for _, entity in World:Exec(ECS.Query.All(Burning, Spread, Health, Position)):Iterator() do
		local burn, spread, life, pos = entity[Burning], entity[Spread], entity[Health], entity[Position]
		
		if life.current > 0 then
			spread.chance = spread.chance - 0.5
			for _, n in ipairs(directNeighbors) do
				local x, y = pos.x + n[1], pos.y + n[2]
				if Dungeon.floor:Has(x, y) then
					local tile = Dungeon.floor:Get(x, y)
					local c = floor(spread.chance)
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
								local hp = min(life.current - 1, Dungeon.wallDistances:Get(x, y))
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