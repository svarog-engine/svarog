local BumpAttackMechanicsSystem = Engine.RegisterEnviroSystem("Bump Attack")

function BumpAttackMechanicsSystem:ShouldTick()
	return Dungeons.created
end

function BumpAttackMechanicsSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Bumped, Position, Health)):Iterator() do
		local who = World:FetchEntityById(entity[Bumped].by)

		local totalDamage = BumpAttackMechanicsSystem:CalculateDamage(who, entity)
		entity[Health].current = entity[Health].current - totalDamage

		if entity[Health].current <= 0 then 
			World:Remove(entity)
		else
			entity:Unset(Bumped)
		end
	end
end

function BumpAttackMechanicsSystem:CalculateDamage(attackerEntity, targetEntity)
	if attackerEntity == nil or targetEntity == nil then
		return
	end

	local baseDamage = (attackerEntity[BumpAttack] ~= nil and attackerEntity[BumpAttack].damage) or 0

	-- Check for components and add to equation

	local totalDamage = baseDamage

	return totalDamage
end