local ShadowcastSystem = Engine.RegisterEnviroSystem("Shadowcast")

local FOV_algorithm = Algorithms.RecursiveShadowcast
local arc = 2 * math.pi -- full circle

function OnVisible(x, y)
	Dungeon.visibility:Set(x,y, 1)
	Dungeon.visited:Set(x,y, 1)
end

function IsTransparent(x, y)
-- Should discuss more about this condition, for now its going to do the job
	return Dungeon.passable:Get(x, y) or false
end

function ShadowcastSystem:ShouldTick()
	return Dungeons.created and DebugToggle_FOV
end

function ShadowcastSystem:Tick()
	local radius = Config.FOVRadius
	local playerPosition = PlayerEntity[Position]
	Dungeon.visibility:Reset(0)

	FOV_algorithm(playerPosition.x, playerPosition.y, radius, IsTransparent, OnVisible, 0, arc)
end