
local DungeonRenderSystem = Engine.RegisterRenderSystem()

function DungeonRenderSystem:Render()	
	local map = DungeonEntity[Dungeon].map
	for _, k in map:Iterate() do
		local tile = map.tiles[k]
		if tile.value.type == Floor then
			Engine.Glyph(tile.x, tile.y, ".", Colors.White, Colors.Black)
		else
			local glyph = tile.value.entity[Glyph]
			Engine.Glyph(tile.x, tile.y, glyph.char, glyph.fg or Colors.White, glyph.bg or Colors.Black)
		end
	end
end

