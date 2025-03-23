local BumpAttackMechanicsSystem = Engine.RegisterEnviroSystem("Bump Attack")

local function CalculateDamage(attackerEntity, targetEntity)
	local baseDamage = (attackerEntity[BumpAttack] ~= nil and attackerEntity[BumpAttack].damage) or 0
	-- Check for components and add to equation

	local totalDamage = baseDamage

	return totalDamage
end

local function PerformAttack(attackerEntity, targetEntity)
		local totalDamage = CalculateDamage(attackerEntity, targetEntity)

		if targetEntity[Silenced] == nil and targetEntity[Endure] ~= nil and Chances[3 + targetEntity[Endure].level]:MakeGuess() then
			if targetEntity == PlayerEntity then
				Diary.Write("You felt nothing. Your [ENDURE] glyph quivers.")
				targetEntity[Tension]:Up()
			else
				Diary.Write(targetEntity[Name].value .. " seems to endure through the beating.")
			end

			Fade(targetEntity, Colors.Magenta, Colors.Black, 0.5)
		else
			targetEntity[Health].current = targetEntity[Health].current - totalDamage
			if targetEntity[Tension] ~= nil then targetEntity[Tension]:Up() end
			Fade(targetEntity, Colors.Red, Colors.Black, 0.5)

			if attackerEntity == PlayerEntity then
				Diary.Write("You hit the " .. targetEntity[Name].value .. ".")
			else
				Diary.Write("The " .. attackerEntity[Name].value .. " hits " .. targetEntity[Name].value .. ".")
			end
		end
end

local function TryBreak(attackerEntity, targetEntity)
	if targetEntity[Breakable] ~= nil and attackerEntity[Break] ~= nil then

		if attackerEntity[Silenced] == nil and Chances[attackerEntity[Break].chance]:MakeGuess() then
			if attackerEntity == PlayerEntity then 
				Diary.Write("You broke " .. targetEntity[Name].value .. "! Your [BREAK] glyph quivers.")
				attackerEntity[Tension]:Up()
			end

			if targetEntity[Contents] ~= nil then
				local position = targetEntity[Position]
				Contents.DropOne(entity, position.x, position.y)
			end

			targetEntity:Unset(Bumped)
			RemoveEntityFromDungeon(targetEntity)
			World:Remove(targetEntity)

			return true
		end
	end

	return false
end

local function TryCalm(attackerEntity, targetEntity)
	local calm = targetEntity[Calm]
	if targetEntity[Silenced] == nil and calm ~= nil and Chances[calm.chance]:MakeGuess() then
		if targetEntity == PlayerEntity then
			Diary.Write("The " .. attackerEntity[Name].value .. " stops! Your [CALM] glyph quivers.")
			targetEntity[Tension]:Up()
		end

		targetEntity:Unset(Bumped)

		return true
	end

	return false
end

local function TryLuck(attackerEntity, targetEntity)
	if targetEntity[Silenced] == nil and targetEntity[Luck] ~= nil and Chances[targetEntity[Luck].chance]:MakeGuess() then
		if targetEntity == PlayerEntity then
			Diary.Write("The " .. attackerEntity[Name].value .. " misses! Your [LUCK] glyph quivers.")
			targetEntity[Tension]:Up()
		end

		if attackerEntity == PlayerEntity then
			Diary.Write("The " .. targetEntity[Name].value .. " got lucky. You miss.")
		end

		targetEntity:Unset(Bumped)

		return true
	end

	return false
end

local function TryYearn(attackerEntity, targetEntity)
	local yearn = targetEntity[Yearn]
	if targetEntity[Silenced] == nil and yearn ~= nil and Chances[yearn.chance]:MakeGuess() then
		if targetEntity == PlayerEntity then
			Diary.Write("The " .. attackerEntity[Name].value .. " stops! Your [YEARN] glyph quivers.")
			attackerEntity:Set(Yearn{})
			targetEntity[Tension]:Up()
		end

		targetEntity:Unset(Bumped)

		return true
	end

	return false
end

local function CheckInflictStatus(entity, target)
	local darken = entity[Darken]
	if entity[Silenced] == nil and darken ~= nil and Chances[darken.chance]:MakeGuess() then
		target:Set(InflictStatus{ component = function() return Blindness { current = 3, maximum = 3 } end })
	end
end

function BumpAttackMechanicsSystem:ShouldTick()
	return Dungeons.created
end

local function Swap(a, b)
	local x, y = a[Position].x, a[Position].y
	RemoveEntityFromDungeon(a)
	a[Position].x = b[Position].x
	a[Position].y = b[Position].y
	AddEntityToDungeon(a[Position].x, a[Position].y, a)

	RemoveEntityFromDungeon(b)
	b[Position].x = x
	b[Position].y = y
	AddEntityToDungeon(x, y, b)

	b:Unset(Bumped)
	b[Creature].actions = -1
end

function BumpAttackMechanicsSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Bumped, Position).Any(Health, Breakable)):Iterator() do
		local who = World:FetchEntityById(entity[Bumped].by)
		if entity ~= nil and who ~= nil then
			local shouldEnd = false
			shouldEnd = shouldEnd or TryLuck(who, entity)
			shouldEnd = shouldEnd or TryYearn(who, entity)
			--shouldEnd = shouldEnd or TryCalm(who, entity)

			CheckInflictStatus(who, entity)
			shouldEnd = shouldEnd or TryBreak(who, entity)

			if who[Creature] ~= nil and entity[Creature] ~= nil and who[Blindness] == nil then
				if Chances[8]:MakeGuess() then Swap(who, entity) end
				shouldEnd = true
			end

			if entity[Health] ~= nil and not shouldEnd then
				PerformAttack(who, entity)

				entity:Unset(Bumped)

				if entity[Health].current <= 0 then
					if entity == PlayerEntity then
						PlayerEntity:Set(Death{ reason = "Killed in combat (" .. who[Name].value .. ")" })
						Input.Push("Death")
						return
					elseif who == PlayerEntity then
						local killVerbs = { "kill", "dispatch", "deal with", "end" }
						Diary.Write("You " .. killVerbs[Rand:Range(1, #killVerbs)] .. " the " .. entity[Name].value .. ".")
					end

					entity[InLevel].value = entity[InLevel].value - 1
					local x, y = entity[Position].x, entity[Position].y

					if entity[Contents] ~= nil then 
						Contents.DropAll(entity, x, y)
					end

					local explodesFire = entity[ExplodeFireOnDeath] ~= nil
					
					RemoveEntityFromDungeon(entity)
					World:Remove(entity)

					if explodesFire then
						for i = -2, 2 do
							for j = -2, 2 do
								if Chances[9]:MakeGuess() then
									Procgen.MakeObject("Flame", x + i, y + j)
								end
							end
						end
					end
				else
					if entity[HideIfHit] ~= nil then
						if Chances[7]:MakeGuess() then
							PCExplode(entity, Colors.Red, Colors.Black, function()
								local px, py = entity[Position].x, entity[Position].y
								for i = -5, 5 do
									for j = -5, 5 do
										if not (i == 0 and j == 0) then
											local nx, ny = px + i, py + j
											if Dungeon.floor:Has(nx, ny) and Dungeon.floor:Get(nx, ny).type == Floor then
												local id = Dungeon.floor:ID(nx, ny)
												local entities = Dungeon.entities[id] or {}
												if #entities == 0 and not Dungeon.visibility:Get(nx, ny) then
													local dist = Dungeon.playerDistance:Get(nx, ny)
													if dist > 2 then
														RemoveEntityFromDungeon(entity)
														entity[Position].x = nx
														entity[Position].y = ny
														AddEntityToDungeon(nx, ny, entity)
														entity:Set(Hidden{ duration = Rand:Range(2, 4) })
														Diary.Write("The " .. entity[Name].value .. " disappears in a puff of smoke.")
														return
													end
												end
											end
										end
									end
								end
							end)
						end
					elseif entity[SplitOnHit] ~= nil then
						if Chances[3]:MakeGuess() then
							local half = math.floor(entity[Health].current / 2)
							if half > 1 then
								local pos = entity[Position]
								entity[Health].current = half
								for i = -1, 1 do
									for j = -1, 1 do
										local nx, ny = pos.x + i, pos.y + j
										if Dungeon.floor:Get(nx, ny).type == Floor then
											local id = Dungeon.floor:ID(nx, ny)
											local entities = Dungeon.entities[id] or {}
											if #entities == 0 then
												local e = Procgen.MakeObject(entity[SplitOnHit].what, nx, ny)
												Diary.Write("The " .. entity[Name].value .. " splits itself into two!")
												e[Health].current = half
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end