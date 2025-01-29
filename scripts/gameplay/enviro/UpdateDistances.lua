
local UpdateDistancesSystem = Engine.RegisterEnviroSystem()

function UpdateDistancesSystem:Update()
	StartMeasure()
	if Dungeon.created then
		Dungeon.playerDistance = Dungeon.floor:DijkstraByClass({ { Player, 0 } }, PassableInDungeon, 10)
	end
	EndMeasure("Update Distances")
end