
local RandomGlyphTestSystem = Engine.RegisterRenderSystem();

function RandomGlyphTestSystem:Render()
	for i = 0, Config.WorldWidth - 1 do
		for j = 0, Config.WorldHeight - 1 do
			Engine.Glyph(i, j, ".", Rand:Color(), Rand:Color())
		end
	end
end

