local ParalyzedResolveSystem = Engine.RegisterEnviroSystem("Paralyzed Resolve Damage")

function ParalyzedResolveSystem:ShouldTick()
	return Dungeons.created
end

local ceil = math.ceil

function ParalyzedResolveSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Paralyzed)):Iterator() do
		entity[Paralyzed].current = entity[Paralyzed].current - 1
		if entity[Paralyzed].current <= 0 then
			entity:Unset(Paralyzed)
		end
	end
end