
local DebugDijkstraRenderSystem = Engine.RegisterRenderSystem()

function DebugDijkstraRenderSystem:Render()
	if DebugToggle_Dijkstra then
		if Dungeon.created then
			for _, k in Dungeon.playerDistance:Iterate() do
				local tile = Dungeon.playerDistance.tiles[k]
				local char = ""
				local neg = tile.value < 0
				local color = Colors.LightBrown
				if neg then color = Colors.Brown end

				local val = math.abs(math.floor(tile.value + 0.5))
			
				if val < 10 then
					char = "" .. val
				elseif val < 36 then
					char = string.sub("abcdefghijklmnopqrstuvwxyz", val - 9, val - 9)
				else 
					char = "empty_tile"
				end

				Engine.Glyph(tile.x, tile.y, char, { fg = color })
			end
		end
	end
end