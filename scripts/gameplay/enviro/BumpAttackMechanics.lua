local BumpAttackMechanicsSystem = Engine.RegisterEnviroSystem("Bump Attack")

local function CalculateDamage(attackerEntity, targetEntity)
	local baseDamage = (attackerEntity[BumpAttack] ~= nil and attackerEntity[BumpAttack].damage) or 0
	-- Check for components and add to equation

	local totalDamage = baseDamage

	return totalDamage
end

local function PerformAttack(attackerEntity, targetEntity)
		local totalDamage = CalculateDamage(attackerEntity, targetEntity)

		if targetEntity[Endure] ~= nil and Chances[5 + targetEntity[Endure].level]:MakeGuess() then
			if targetEntity == PlayerEntity then
				Diary.Write("You felt nothing. Your [ENDURE] glyph quivers.")
				targetEntity[Tension]:Up()
			else
				Diary.Write(targetEntity[Name].value .. " seems to endure through the beating.")
			end

			Fade(targetEntity, Colors.Magenta, Colors.Black, 0.5)
		else
			targetEntity[Health].current = targetEntity[Health].current - totalDamage
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

		if Chances[attackerEntity[Break].chance]:MakeGuess() then
			-- print("Broke entity -> ID: " .. targetEntity)

			if attackerEntity == PlayerEntity then 
				Diary.Write("You broke " .. targetEntity[Name].value .. "! Your [BREAK] glyph quivers.")
				attackerEntity[Tension]:Up()
			end

			if targetEntity[Contents] ~= nil then
				local position = targetEntity[Position]
				Contents.DropOne(entity, position.x, position.y)
			end

			RemoveEntityFromDungeon(targetEntity)
			targetEntity:Unset(Bumped)
			World:Remove(targetEntity)

			return true
		end
	end

	return false
end

local function TryCalm(attackerEntity, targetEntity)
	local calm = targetEntity[Calm]
	if calm ~= nil and Chances[calm.chance]:MakeGuess() then
		if targetEntity == PlayerEntity then
			Diary.Write("The " .. attackerEntity[Name].value .. " stops! Your [CALM] glyph quivers.")
			targetEntity[Tension]:Up()
		end

		targetEntity:Unset(Bumped)

		return true
	end

	return false
end

local function TryYearn(attackerEntity, targetEntity)
	local yearn = targetEntity[Yearn]
	if yearn ~= nil and Chances[yearn.chance]:MakeGuess() then
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
	if darken ~= nil and Chances[darken.chance]:MakeGuess() then
		target:Set(InflictStatus{ component = function() return Blindness { current = 3, maximum = 3 } end })
	end
end

function BumpAttackMechanicsSystem:ShouldTick()
	return Dungeons.created
end

function BumpAttackMechanicsSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Bumped, Position).Any(Health, Breakable)):Iterator() do
		local who = World:FetchEntityById(entity[Bumped].by)
		if entity ~= nil and who ~= nil then

			if TryYearn(who, entity) then
				return
			end

			if TryCalm(who, entity) then
				return
			end

			CheckInflictStatus(who, entity)
			if TryBreak(who, entity) then
				return
			end

			if entity[Health] ~= nil then
				PerformAttack(who, entity)

				entity:Unset(Bumped)

				if entity[Health].current <= 0 then
					if entity == PlayerEntity then
						Svarog.Instance:Reload()
						return
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
								if Chances[5]:MakeGuess() then
									Procgen.MakeObject("Flame", x + i, y + j)
								end
							end
						end
					end
				end
			end
		end
	end
end