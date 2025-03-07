local ShadowcastSystem = Engine.RegisterEnviroSystem("Shadowcast")

local FOV_algorithm = Algorithms.RecursiveShadowcast
local arc = 2 * math.pi -- full circle

function OnVisible(x, y)
	Dungeon.visibility:Set(x, y, 1)
	Dungeon.visited:Set(x, y, 1)
	Dungeon.memory:Set(x, y, 1)
end

function IsTransparent(x, y)
-- Should discuss more about this condition, for now its going to do the job
	if Dungeon.passable:Has(x, y) then
		return Dungeon.passable:Get(x, y)
	else
		return false
	end
end

function ShadowcastSystem:ShouldTick()
	return PlayerEntity ~= nil and Dungeons.created and DebugToggle_FOV
end

function ShadowcastSystem:Tick()
	local radius = PlayerEntity[Sight].radius + PlayerEntity[Pause].duration
	local playerPosition = PlayerEntity[Position]
	Dungeon.visibility:Reset(false)

	local light = PlayerEntity[Light]
	if light ~= nil then
		if Chances[light.chance]:MakeGuess() then
			radius = radius + light.bonusRadius
			IncreaseTension(PlayerEntity, light.level)
		end
	end

	local blindness = PlayerEntity[Blindness]
	if blindness ~= nil then
		radius = 1
	end

	FOV = {}
	FOV_algorithm(playerPosition.x, playerPosition.y, radius, IsTransparent, OnVisible, 0, arc)
end