
local UpdateDistancesSystem = Engine.RegisterEnviroSystem("Update Distances")

function UpdateDistancesSystem:ShouldTick()
	return Dungeons.created and Dungeon.playerDistance ~= nil and PlayerEntity ~= nil
end

function UpdateDistancesSystem:Tick()
	Dungeon.playerDistance.goals = { { PlayerEntity[Position].x, PlayerEntity[Position].y } }
	Dungeon.playerDistance:Flood()
end