local BumpAttackMechanicsSystem = Engine.RegisterEnviroSystem("Bump Attack")

function BumpAttackMechanicsSystem:ShouldTick()
	return Dungeons.created
end

function BumpAttackMechanicsSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Bumped, Position, Health)):Iterator() do
		local who = World:FetchEntityById(entity[Bumped].by)

		if entity ~= nil and who ~= nil then
			local totalDamage = BumpAttackMechanicsSystem:CalculateDamage(who, entity)
			entity[Health].current = entity[Health].current - totalDamage

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