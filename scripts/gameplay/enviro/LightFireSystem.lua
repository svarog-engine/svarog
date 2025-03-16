
local LightFireSystem = Engine.RegisterEnviroSystem("Light Fire")

local function Distance(x1, y1, x2, y2)
	local dx, dy = x1 - x2, y1 - y2
	return math.sqrt(dx * dx + dy * dy)
end

function LightFireSystem:ShouldTick()
	return Dungeon ~= nil and PlayerEntity ~= nil and PlayerEntity[Light] ~= nil
end

function LightFireSystem:Tick()
	local helped = 0
	local px, py = PlayerEntity[Position].x, PlayerEntity[Position].y

	for _, entity in World:Exec(ECS.Query.All(Burning, Position).None(Spread, Health)):Iterator() do
		local ex, ey = entity[Position].x, entity[Position].y
		local d = math.ceil(Distance(px, py, ex, ey))
		
		if d < 10 then
			if Chances[d]:MakeGuess() and Chances[PlayerEntity[Light].chance]:MakeGuess() then
				entity:Set(Health(Range(5)))
				entity:Set(Spread{ chance = 6 })
				helped = helped + 1
			end
		end
	end

	if helped > 0 then
		Diary.Write("Flames burst free. Your [LIGHT] glyph is satisfied.")
		PlayerEntity[Tension]:Up()
	end
end
