local InflictStatusSystem = Engine.RegisterEnviroSystem("Inflict Status")

function InflictStatusSystem:ShouldTick()
	return Dungeons.created
end

function InflictStatusSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Bumped, InflictStatus)):Iterator() do
		local who = World:FetchEntityById(entity[Bumped].by)

		local component = entity[InflictStatus].component()
		if component ~= nil then
			who:Set(component)
		end
	end
end