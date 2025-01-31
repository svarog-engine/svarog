
local DungeonRenderSystem = Engine.RegisterRenderSystem()

function DungeonRenderSystem:Render()	
	if Dungeon.floor ~= nil then
		local w, h = Dungeon.floor:Size()
		for x = 1, w do
			for y = 1, h do
				if Dungeon.floor:Has(x, y) then
					local tile = Dungeon.floor:Get(x, y)
					if tile.type == Floor then
						Engine.Glyph(x, y, "back_dark")
					else
						local glyph = tile.entity[Glyph]
						Engine.Glyph(x, y, glyph.name)
					end
				end
			end
		end
	end
end

