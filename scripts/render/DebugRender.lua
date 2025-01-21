
local DebugRenderSystem = Engine.RegisterRenderSystem();

function DebugRenderSystem:Update()
	if Input.Peek() == "Debug" then
		for i = 0, Options.WorldWidth - 1 do
			for j = 0, 1 do
				Glyphs[i][j].Presentation = " "
				Glyphs[i][j].Foreground = Colors.Black
				Glyphs[i][j].Background = Colors.Red
			end
		end

		Engine.Write(2, 0, "debug", Colors.Black, Colors.Red)
	end 
end
