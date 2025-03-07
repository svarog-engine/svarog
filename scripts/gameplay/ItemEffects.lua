ItemConsume = { 
	ash = function() return Break end,
	frankincense = function() return Light end,
	blackthorn = function() return Darken end,
	willow = function() return Luck end,
	sage = function() return Endure end,
	foxglove = function() return Heal end,
	mandrake = function() return Luck end,
}

function CanConsume(itemId)
	return ItemConsume[itemId] ~= nil
end

function Consume(itemId)
	local component = ItemConsume[itemId]
	if component == nil then
		return
	end

	if PlayerEntity[component()] then
		PlayerEntity[Tension]:Down(1)
	end
end

ItemCast = {
	diamond = function() return Break end,
	topaz = function() return Light end,
	obsidian = function() return Darken end,
	malachite = function() return Luck end,
	lapis_lazuli = function() return Endure end,
	onyx = function() return Heal end,
	smoky_quartz = function() return Luck end,
}

function CanCast(itemId)
	return ItemCast[itemId] ~= nil
end

function Cast(x, y, itemId)
	local component = ItemCast[itemId]
	if component == nil then
		return
	end

	local id = Dungeon.floor:ID(x, y)
	local entities = Dungeon.entities[id] or {}

	for _, e in ipairs(entities) do
		if e[Creature] ~= nil then
			local comp = component()
			if e[comp] ~= nil then
				if e[Contents] ~= nil then 
					local position = e[Position]
					Contents.DropAll(e, position.x, position.y)
				end

				RemoveEntityFromDungeon(e)
				World:Remove(e)
			else
				e:Set(comp(), Magic{})
			end
		end
	end
end