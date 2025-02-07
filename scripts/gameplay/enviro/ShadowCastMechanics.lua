

local ShadowcastSystem = Engine.RegisterEnviroSystem()

local FOV_algorithm = Algorithms.RecursiveShadowcast
local arc = 2 * math.pi -- full circle

function OnVisible(x, y)
	Dungeon.visibility:Set(x,y,1)
	Dungeon.visited:Set(x,y, 1)
end

function IsTransparent(x, y)
-- Should discuss more about this condition, for now its going to do the job
	if Dungeon.passable:Has(x,y) then
		return Dungeon.passable:Get(x,y)
	else
		return false
	end
end

function ShadowcastSystem:Update()
	StartMeasure()
	if Dungeon.created and DebugToggle_FOV then
		local radius = Config.FOVRadius
		local playerPosition = PlayerEntity[Position]
		Dungeon.visibility:Reset(0)

		FOV_algorithm(playerPosition.x, playerPosition.y, radius, IsTransparent, OnVisible, 0, arc)
	end
	EndMeasure("Shadowcast")
end