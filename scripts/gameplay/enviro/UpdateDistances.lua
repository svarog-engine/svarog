
local UpdateDistancesSystem = Engine.RegisterEnviroSystem("Update Distances")

function UpdateDistancesSystem:ShouldTick()
	return Dungeons.created and Dungeons.playerDistance ~= nil
end

function UpdateDistancesSystem:Tick()
	Dungeons.playerDistance.goals = { { PlayerEntity[Position].x, PlayerEntity[Position].y } }
	Dungeons.playerDistance:Flood()
end