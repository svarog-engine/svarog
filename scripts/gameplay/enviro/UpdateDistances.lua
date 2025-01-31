
local UpdateDistancesSystem = Engine.RegisterEnviroSystem()

function UpdateDistancesSystem:Update()
	StartMeasure()
	if Dungeon.created then
		Dungeon.playerDistance:DijkstraByClass(Dungeon.floor, { { Player, 0 } }, PassableInDungeon, 40)
	end
	EndMeasure("Distances")
end