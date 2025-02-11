
local DungeonRenderSystem = Engine.RegisterRenderSystem()

function DungeonRenderSystem:Render()	
	if Dungeon.floor ~= nil then
		local w, h = Dungeon.floor:Size()
		for x = 1, w do
			for y = 1, h do
				if Dungeon.floor:Has(x, y) then
					local tile = Dungeon.floor:Get(x, y)
					if tile.type == Floor then
						if Dungeon.visited:Get(x,y) == 0 then
							Engine.Glyph(x, y, nil, { fg = Colors.Black, bg = Colors.Black} )
						elseif  Dungeon.visibility:Get(x,y) == 0 then
							Engine.Glyph(x, y, "back_dark")
						else
							Engine.Glyph(x, y, "back_dark")
						end
					elseif tile.type == Wall or (tile.type == Door and tile.entity[Door].hidden) then
						Engine.Glyph(x, y, "wall", { fg = Colors.White, bg = Colors.DarkGray } )
					else
						local glyph = tile.entity[Glyph]
						Engine.Glyph(x, y, glyph.name)
					end
				end
			end
		end
	end
end

