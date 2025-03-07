
local PlatformSystem = Engine.RegisterEnviroSystem("Platforms")

function PlatformSystem:ShouldTick()
	return Dungeons.created
end

function PlatformSystem:Tick()
	for _, entity in World:Exec(ECS.Query.All(Platform, Position)):Iterator() do
		local position = entity[Position]
		local platform = entity[Platform]

		local id = Dungeon.floor:ID(position.x, position.y)
		local entities = Dungeon.entities[id] or {}

		for _, e in ipairs(entities) do
			if e ~= entity then
				if platform.canActivate ~= nil and platform.activate ~= nil then
					if (platform.canActivate(e)) then 
						platform.activate(e)

						if platform.removeWhenActivated then
							World:Remove(entity)
						end

						break
					end
				end
			end
		end
	end
end