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
	local id = Dungeon.floor:ID(x, y)
	local entts = Dungeon.entities[id] or {}
	if #entts > 0 then 
		return Dungeon.passable:Get(x, y)
	else
		local typ = Dungeon.floor:Get(x, y).type
		if typ == Wall then
			return false
		elseif typ ~= Floor then
			return Dungeon.passable:Get(x, y)
		else
			return true
		end
	end
end

--		if Dungeon.visibility:Has(x, y) then
--			return Dungeon.visibility:Get(x, y)
--		else
--			return false
--		end


function ShadowcastSystem:ShouldTick()
	return PlayerEntity ~= nil and Dungeons.created
end

function ShadowcastSystem:Tick()
	local radius = PlayerEntity[Sight].radius + PlayerEntity[Pause].duration
	local playerPosition = PlayerEntity[Position]
	Dungeon.visibility:Reset(false)

	local blindness = PlayerEntity[Blindness]	
	if PlayerEntity[Light] ~= nil then
		radius = math.ceil(2 * radius)
	end

	FOV = {}

	if blindness == nil then
		FOV_algorithm(playerPosition.x, playerPosition.y, radius, IsTransparent, OnVisible, 0, arc)
	end
end