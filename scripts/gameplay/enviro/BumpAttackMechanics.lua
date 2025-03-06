local BumpAttackMechanicsSystem = Engine.RegisterEnviroSystem("Bump Attack")

local function CalculateDamage(attackerEntity, targetEntity)
	local baseDamage = (attackerEntity[BumpAttack] ~= nil and attackerEntity[BumpAttack].damage) or 0
	-- Check for components and add to equation

	local totalDamage = baseDamage

	return totalDamage
end

local function PerformAttack(attackerEntity, targetEntity)
		local totalDamage = CalculateDamage(attackerEntity, targetEntity)

		if targetEntity[Endure] ~= nill then
			if targetEntity[Delayed] == nill then
				targetEntity:Set(Delayed{ damage = 0, current = 8, maximum = 8 })
			end

			targetEntity[Delayed].damage = targetEntity[Delayed].damage + totalDamage

			if targetEntity[Delayed].damage < targetEntity[Endure].turns then
				targetEntity[Delayed].current = targetEntity[Delayed].damage
				targetEntity[Delayed].maximum = targetEntity[Delayed].damage
			else
				targetEntity[Delayed].current = targetEntity[Endure].turns
				targetEntity[Delayed].maximum = targetEntity[Endure].turns
			end

			Diary.Write("Endure activated! You going to receive damage over time.")

		else
			targetEntity[Health].current = targetEntity[Health].current - totalDamage
			Fade(targetEntity, Colors.Red, Colors.Black, 0.5)
		end
end

local function TryBreak(attackerEntity, targetEntity)
	if targetEntity[Breakable] ~= nil and attackerEntity[Break] ~= nil then

		if Chances[attackerEntity[Break].chance]:MakeGuess() then
			-- print("Broke entity -> ID: " .. targetEntity)

			if attackerEntity == PlayerEntity then 
				Diary.Write("You broke something!")
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
			Diary.Write("You calm the creature down!")
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
					RemoveEntityFromDungeon(entity)
					World:Remove(entity)
				end
			end
		end
	end
end