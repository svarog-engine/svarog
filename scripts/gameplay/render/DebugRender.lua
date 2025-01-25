
local DebugRenderSystem = Engine.RegisterRenderSystem();

function DebugRenderSystem:Render()
	if Input.Peek() == "Debug" then
		Engine.Line(0, " ", Colors.Black, Colors.Red)
		Engine.Line(1, " ", Colors.Black, Colors.Red)

		Engine.Write(2, 0, "debug", Colors.Black, Colors.Red)
		Engine.Write(15, 0, "[f5] reload", Colors.Black, Colors.Red)
	end 
end
