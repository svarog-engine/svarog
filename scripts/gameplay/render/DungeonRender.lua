﻿
local DungeonRenderSystem = Engine.RegisterRenderSystem()

function DungeonRenderSystem:Render()	
	local map = DungeonEntity[Dungeon].map
	if map ~= nil then
		for _, k in map:Iterate() do
			local tile = map.tiles[k]
			if tile.value.type == Floor then
				Engine.Glyph(tile.x, tile.y, "back_dark")
			else
				local glyph = tile.value.entity[Glyph]
				Engine.Glyph(tile.x, tile.y, glyph.name)
			end
		end
	end
end

