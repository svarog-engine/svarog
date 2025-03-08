
local WinScreenRenderSystem = Engine.RegisterRenderSystem("Win Screen")

function WinScreenRenderSystem:ShouldRender()
	return Dungeon ~= nil and Dungeon.floor ~= nil
end

local space = nil
WinScreenFrame = 60
WinScreenWay = "up"
FIN = true

function WinScreenRenderSystem:Render()
	if not FIN then return end
	
	local w, h = Dungeon.floor:Size()
	if space == nil then
		space = Map:New(w, h)
		for i = 1, w do
			for j = 1, h do 
				space:Set(i, j, Rand:Range(1, 30))
			end
		end
		frame = 60
	end
	
	if WinScreenWay == "down" then
		WinScreenFrame = WinScreenFrame - 1
	elseif WinScreenWay == "up" then
		WinScreenFrame = WinScreenFrame + 1
	end
	
	for i = 1, w do
		for j = 1, h do 
			if space:Get(i, j) < WinScreenFrame then
				Engine.Glyph(i, j, "empty", { bg = Colors.Black, fg = Colors.Black })
			end
		end
	end

	if WinScreenFrame > 30 then
		Engine.Write(math.floor(w / 2) - 4, 15, "B E N E A T H")
		Engine.Write(math.floor(w / 2) - 4, 17, " THE  THRONE ")
		Engine.Write(math.floor(w / 2) - 4, 18, "    of the   ")
		Engine.Write(math.floor(w / 2) - 4, 20, "GOBLIN  QUEEN")
		Engine.Write(math.floor(w / 2) - 4, 22,     "     ----    ")
		if WinScreenFrame > 40 then
			Engine.Write(math.floor(w / 2) - 4, 25, "Team   SVAROG ")
		end
		if WinScreenFrame > 50 then
			if math.floor(WinScreenFrame / 10) % 2 == 0 then
				Engine.Write(math.floor(w / 2) - 8, 31, "P R E S S   S P A C E")
			end
		end
	end

	if WinScreenWay == "up" and WinScreenFrame > 60 then
		WinScreenFrame = 60
	end

	if WinScreenWay == "down" and WinScreenFrame == 0 then
		FIN = false
		WinScreenWay = "up"
	end
end

