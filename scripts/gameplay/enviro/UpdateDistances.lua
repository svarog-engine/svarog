
local UpdateDistancesSystem = Engine.RegisterEnviroSystem()

function UpdateDistancesSystem:Update()
	StartMeasure()
	if Dungeons.created then
		Dungeons.playerDistance.goals = { { PlayerEntity[Position].x, PlayerEntity[Position].y } }
		Dungeons.playerDistance:Flood()
	end
	EndMeasure("Distances")
end