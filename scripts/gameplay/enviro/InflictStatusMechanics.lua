local InflictStatusSystem = Engine.RegisterEnviroSystem("Inflict Status")

function InflictStatusSystem:ShouldTick()
	return Dungeons.created
end

function InflictStatusSystem:Tick()

	for _, entity in World:Exec(ECS.Query.All(Bumped, ProvideStatus)):Iterator() do
		local who = World:FetchEntityById(entity[Bumped].by)
		local provideStatusComp = entity[ProvideStatus]

		if provideStatusComp ~= nil then
			who:Set(InflictStatus{component = provideStatusComp.component })
		end
	end

	for _, entity in World:Exec(ECS.Query.All(InflictStatus)):Iterator() do

		local component = entity[InflictStatus].component()
		if component ~= nil then
			entity:Set(component)
		end

		entity:Unset(InflictStatus)
	end
end