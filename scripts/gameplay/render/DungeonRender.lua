
local DungeonRenderSystem = Engine.RegisterRenderSystem()

function DungeonRenderSystem:Render()	
	if Dungeon.floor ~= nil then
		for _, k in Dungeon.floor:Iterate() do
			local tile = Dungeon.floor.tiles[k]
			if tile.value.type == Floor then
				Engine.Glyph(tile.x, tile.y, "back_dark")
			else
				local glyph = tile.value.entity[Glyph]
				Engine.Glyph(tile.x, tile.y, glyph.name)
			end
		end
	end
end

