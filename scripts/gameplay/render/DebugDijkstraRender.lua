
local DebugDijkstraRenderSystem = Engine.RegisterRenderSystem()

function DebugDijkstraRenderSystem:Render()
	if DebugToggle_Dijkstra then
		local map = Dungeon.dist
		if map ~= nil then
			for _, k in map:Iterate() do
				local tile = map.tiles[k]
				local char = ""
				local neg = tile.value < 0
				local color = Colors.White
				if neg then color = Colors.Red end

				local val = math.abs(math.floor(tile.value + 0.5))
			
				if val < 10 then
					char = "" .. val
				elseif val < 36 then
					char = string.sub("abcdefghijklmnopqrstuvwxyz", val - 9, val - 9)
				else 
					char = "empty"
				end

				Engine.Glyph(tile.x, tile.y, char, { fg = color })
			end
		end
	end
end