
local DebugDistancesRenderSystem = Engine.RegisterRenderSystem()

local Palette = {}
Palette[0] = Colors.Gray
Palette[1] = Colors.DarkBlue
Palette[2] = Colors.Blue
Palette[3] = Colors.LightBlue
Palette[4] = Colors.Cyan
Palette[5] = Colors.Green
Palette[6] = Colors.LightGreen
Palette[7] = Colors.Yellow
Palette[-1] = Colors.DarkRed
Palette[-2] = Colors.Red
Palette[-3] = Colors.LightRed
Palette[-4] = Colors.DarkBrown
Palette[-5] = Colors.Brown
Palette[-6] = Colors.LightBrown

function DebugDistancesRenderSystem:Render()
	if DebugToggle_DistanceIndex > 0 then
		local map = Dungeons.playerDistance
		if DebugToggle_DistanceIndex == 2 then
			map = Dungeons.wallDistances
		end

		if Dungeons.created then
			local w, h = map:Size()
			for i = 1, w do
				for j = 1, h do
					if map:Has(i, j) then
						local tile = map:Get(i, j)
						local char = ""
						local neg = tile < 0
						local color = Palette[tile] or Colors.White

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