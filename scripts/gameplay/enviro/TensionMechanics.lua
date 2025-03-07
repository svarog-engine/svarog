
local TensionSystem = Engine.RegisterEnviroSystem("Tension")

function TensionSystem:ShouldTick()
	return Dungeons.created
end

function TensionSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Tension, TensionDecrease)):Iterator() do
		local tension = entity[Tension]
		local decrease = entity[TensionDecrease]

		tension.current = tension.current - decrease.value
		if tension.current < 0 then
			tension.current = 0
		end

		entity:Unset(TensionDecrease)

		if (tension.current < tension.maximum) and entity[TensionLimitReached] ~= nil then
			entity:Unset(TensionLimitReached)
		end
	end

	for _, entity in World:Exec(ECS.Query.All(Tension, TensionIncrease).None(TensionLocked)):Iterator() do
		local tension = entity[Tension]
		local increase = entity[TensionIncrease]
		tension.current = Clamp(tension.current + increase.value, tension.maximum)

		entity:Unset(TensionIncrease)

		if (tension.current == tension.maximum) then
			entity:Set(TensionLimitReached())
		end
	end
end

function IncreaseTension(entity, n)
	if entity[TensionLocked] ~= nil then
		return
	end

	local n = n or 1
	if entity[TensionIncrease] == nil then
		entity:Set(TensionIncrease{ value = 0 })
	end

	entity[TensionIncrease].value = entity[TensionIncrease].value + n
end

function DecreaseTension(entity, n)
	local n = n or 1
	if entity[TensionDecrease] == nil then
		entity:Set(TensionDecrease{ value = 0 })
	end

	entity[TensionDecrease].value = entity[TensionDecrease].value + n
end