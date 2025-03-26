
local TimeoutCounterRenderSystem = Engine.RegisterRenderSystem("Timeout Counter Render")

local ceil = math.ceil

local digitsToString = {
	[0] = "0",
	[1] = "1",
	[2] = "2",
	[3] = "3",
	[4] = "4",
	[5] = "5",
	[6] = "6",
	[7] = "7",
	[8] = "8",
	[9] = "9",
}

local Time = 0
function TimeoutCounterRenderSystem:Render()
	Time = Time + 1

	for _, entity in World:Exec(ECS.Query.All(Timeout, Position)):Iterator() do
		local timeout = entity[Timeout]
		local pos = entity[Position]
		local x, y = pos.x, pos.y

		if Time < 10 then
			Engine.Glyph(x, y, digitsToString[ceil(entity[Timeout].value)])
		end
	end
	
	if Time >= 20 then
		Time = 0
	end
end

