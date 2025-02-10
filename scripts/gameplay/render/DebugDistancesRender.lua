
local DebugDistancesRenderSystem = Engine.RegisterRenderSystem()

function DebugDistancesRenderSystem:Render()
	if DebugToggle_Distances then
		if Dungeons.created then
			local w, h = Dungeons.playerDistance:Size()
			for i = 1, w do
				for j = 1, h do
					if Dungeons.playerDistance:Has(i, j) then
						local tile = Dungeons.playerDistance:Get(i, j)
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
							char = "empty_tile"
						end

						Engine.Glyph(i, j, char, { fg = color })
					end
				end
			end
		end
	end
end