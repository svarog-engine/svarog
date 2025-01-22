
local DebugRenderSystem = Engine.RegisterRenderSystem();

function DebugRenderSystem:Render()
	if Input.Peek() == "Debug" then
		for i = 0, Config.WorldWidth - 1 do
			for j = 0, 1 do
				Engine.Write(i, j, " ", Colors.Black, Colors.Red)
			end
		end

		Engine.Write(2, 0, "debug", Colors.Black, Colors.Red)
		Engine.Write(15, 0, "[f5] reload", Colors.Black, Colors.Red)
	end 
end
