local BumpAttackMechanicsSystem = Engine.RegisterEnviroSystem("Bump Attack")

function BumpAttackMechanicsSystem:ShouldTick()
	return Dungeons.created
end

function BumpAttackMechanicsSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Bumped, Position, Health)):Iterator() do
		local who = World:FetchEntityById(entity[Bumped].by)

		if entity ~= nil and who ~= nil then
			local totalDamage = BumpAttackMechanicsSystem:CalculateDamage(who, entity)

			if entity[Endure] ~= nill then
				if entity[Delayed] == nill then
					entity:Set(Delayed{ damage = 0, current = 8, maximum = 8 })
				end

				entity[Delayed].damage = entity[Delayed].damage + totalDamage

				if entity[Delayed].damage < entity[Endure].turns then
					entity[Delayed].current = entity[Delayed].damage
					entity[Delayed].maximum = entity[Delayed].damage
				else
					entity[Delayed].current = entity[Endure].turns
					entity[Delayed].maximum = entity[Endure].turns
				end

				Diary.Write("Endure activated! You going to receive damage over time.")

			else
				entity[Health].current = entity[Health].current - totalDamage
			end

			entity:Unset(Bumped)

			if entity[Health].current <= 0 then
				RemoveEntityFromDungeon(entity)
				World:Remove(entity)
			end
		end
	end
end

function BumpAttackMechanicsSystem:CalculateDamage(attackerEntity, targetEntity)
	local baseDamage = (attackerEntity[BumpAttack] ~= nil and attackerEntity[BumpAttack].damage) or 0
	-- Check for components and add to equation

	local totalDamage = baseDamage

	return totalDamage
end