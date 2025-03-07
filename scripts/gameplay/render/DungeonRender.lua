
local DungeonRenderSystem = Engine.RegisterRenderSystem("Dungeon Render")

function DungeonRenderSystem:ShouldRender()
	return Dungeon ~= nil and Dungeon.floor ~= nil
end

function DungeonRenderSystem:Render()
	local w, h = Dungeon.floor:Size()
	for x = 1, w do
		for y = 1, h do
			if Dungeon.floor:Has(x, y) and Dungeon.visibility:Get(x, y) then
				local tile = Dungeon.floor:Get(x, y)
				if tile.type == Floor then
					if not Dungeon.visited:Get(x, y) then
						Engine.Glyph(x, y, "empty_tile", { fg = Colors.Black, bg = Colors.Black } )
					else
						Engine.Glyph(x, y, "back_dark")
					end
				elseif tile.type == Wall or (tile.type == Door and tile.entity[Door].hidden) then
					Engine.Glyph(x, y, "wall", { fg = Colors.White, bg = Colors.DarkGray } )
				elseif tile.entity ~= nil then
					local glyph = tile.entity[Glyph]
					if glyph ~= nil then
						Engine.Glyph(x, y, glyph.name)
					else
						Svarog.Instance:LogError("GLYPH MISSING ON " .. tile.entity[Name].value)
					end
				end
			elseif Dungeon.memory:Has(x, y) then
				local seen = Dungeon.memory:Get(x, y)
				if seen then
					local tile = Dungeon.floor:Get(x, y)
					if tile.type == Floor then
						Engine.Glyph(x, y, "back_dark", { fg = Colors.DarkBlue, bg = Colors.Black })
					else
						Engine.Glyph(x, y, "wall", { fg = Colors.Gray, bg = Colors.Black } )
					end
				else
					Engine.Glyph(x, y, "empty_tile")
				end
			else
				Engine.Glyph(x, y, "empty_tile")
			end
		end
	end
end

