
local UpdateDistancesSystem = Engine.RegisterEnviroSystem()

function UpdateDistancesSystem:Update()
	StartMeasure()
	if Dungeon.created then
		Dungeon.playerDistance.goals = { { PlayerEntity[Position].x, PlayerEntity[Position].y } }
		Dungeon.playerDistance:Flood()
	end
	EndMeasure("Distances")
end