
local UpdateDistancesSystem = Engine.RegisterEnviroSystem()

function UpdateDistancesSystem:Update()
	if Dungeon.created then
		Dungeon.playerDistance = Dungeon.floor:DijkstraByClass({ { Player, 0 } }, PassableInDungeon)
	end
end