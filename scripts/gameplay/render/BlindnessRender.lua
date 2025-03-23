
local BlindnessRenderSystem = Engine.RegisterRenderSystem("Blindness Render")

local Time = 0
function BlindnessRenderSystem:Render()
	Time = Time + 1

	for _, entity in World:Exec(ECS.Query.All(Creature, Blindness)):Iterator() do
		local timeout = entity[Timeout]
		local pos = entity[Position]
		local x, y = pos.x, pos.y

		if Time < 10 then
			Engine.Glyph(x, y, "X", { fg = Colors.Red })
		end
	end
	
	if Time >= 20 then
		Time = 0
	end
end

