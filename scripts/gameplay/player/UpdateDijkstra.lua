
local UpdateDijkstraSystem = Engine.RegisterPlayerSystem()

function UpdateDijkstraSystem:Update()
	if Dungeon.map ~= nil then
		for _, player in World:Exec(ECS.Query.All(Player, Position, UpdateDijkstra)):Iterator() do
			Dungeon.playerDistance = Dungeon.map:Dijkstra({ 
				{ player[Position].x, player[Position].y } 
			}, 0, function(t) return t.pass end)

			player:Unset(UpdateDijkstra)
		end
	end
end