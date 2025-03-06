local StatusEffectUpdateSystem = Engine.RegisterEnviroSystem("Status Effect")

function StatusEffectUpdateSystem:ShouldTick()
	return Dungeons.created
end

function StatusEffectUpdateSystem:UpdateDuration(entity, statusEffect)
	local effect = entity[statusEffect]

	if effect ~= nil then
		effect.current = effect.current - 1
		if effect.current == 0 then
			entity:Unset(statusEffect)
		end
	end
end

function StatusEffectUpdateSystem:Tick()
	for _, entity in World:Exec(ECS.Query.Any(Telepathic, Invisible, Delayed, Blindness)):Iterator() do
		StatusEffectUpdateSystem:UpdateDuration(entity, Telepathic)
		StatusEffectUpdateSystem:UpdateDuration(entity, Invisible)
		StatusEffectUpdateSystem:UpdateDuration(entity, Delayed)
		StatusEffectUpdateSystem:UpdateDuration(entity, Blindness)
	end
end