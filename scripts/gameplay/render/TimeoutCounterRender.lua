
local TimeoutCounterRenderSystem = Engine.RegisterRenderSystem("Timeout Counter Render")

local Time = 0
function TimeoutCounterRenderSystem:Render()
	Time = Time + 1

	for _, entity in World:Exec(ECS.Query.All(Timeout, Position)):Iterator() do
		local timeout = entity[Timeout]
		local pos = entity[Position]
		local x, y = pos.x, pos.y

		if Time < 20 then
			Engine.Glyph(x, y, tostring(math.ceil(entity[Timeout].value)))
		end
	end
	
	if Time > 40 then
		Time = 0
	end
end

