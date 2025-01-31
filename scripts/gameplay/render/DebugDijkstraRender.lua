
local DebugDijkstraRenderSystem = Engine.RegisterRenderSystem()

function DebugDijkstraRenderSystem:Render()
	if DebugToggle_Dijkstra then
		if Dungeon.created then
			local w, h = Dungeon.playerDistance:Size()
			for i = 1, w do
				for j = 1, h do
					if Dungeon.playerDistance:Has(i, j) then
						local tile = Dungeon.playerDistance.tiles[i][j]
						local char = ""
						local neg = tile < 0
						local color = Colors.LightBrown
						if neg then color = Colors.Brown end

						local val = math.abs(math.floor(tile + 0.5))
			
						if val < 10 then
							char = "" .. val
						elseif val < 36 then
							char = string.sub("abcdefghijklmnopqrstuvwxyz", val - 9, val - 9)
						else 
							char = "empty"
						end

						Engine.Glyph(i, j, char, { fg = color })
					end
				end
			end
		end
	end
end