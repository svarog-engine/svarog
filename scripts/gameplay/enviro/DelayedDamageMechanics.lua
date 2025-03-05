local DelayedDamageMechanicsSystem = Engine.RegisterEnviroSystem("Delayed Damage")

function DelayedDamageMechanicsSystem:ShouldTick()
	return Dungeons.created
end

local ceil = math.ceil

function DelayedDamageMechanicsSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Health, Delayed)):Iterator() do

		local totalDamage = ceil(entity[Delayed].damage / entity[Delayed].current)
		entity[Delayed].damage = entity[Delayed].damage - totalDamage

		entity[Health].current = entity[Health].current - totalDamage

		Diary.Write("You receive a small delayed damage")

		if entity[Delayed].damage <= 0 then 
			entity:Unset(Delayed)
		end

		if entity[Health].current <= 0 then
			Diary.Write("You died from delayed damage")
			RemoveEntityFromDungeon(entity)
			World:Remove(entity)
		end
	end
end