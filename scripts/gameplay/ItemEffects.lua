ItemConsume = { 
	ash = function() return Break end,
	rosebud = function() return Light end,
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
		PlayerEntity[Tension]:Down(5)
	end

	return true
end

ItemCastNames = {
	diamond = function() return "Break" end,
	sapphire = function() return "Light" end,
	obsidian = function() return "Darken" end,
	malachite = function() return "Luck" end,
	lapis_lazuli = function() return "Endure" end,
	onyx = function() return "Heal" end,
	smoky_quartz = function() return "Calm" end,
	garnet = function() return "Flow" end,
	topaz = function() return "Open" end,
}

ItemCast = {
	diamond = function() return Break end,
	sapphire = function() return Light end,
	obsidian = function() return Darken end,
	malachite = function() return Luck end,
	lapis_lazuli = function() return Endure end,
	onyx = function() return Heal end,
	smoky_quartz = function() return Calm end,
	garnet = function() return Flow end,
	topaz = function() return Open end,
}

CompColors = {
	Break = { Colors.LightBlue, Colors.Blue },
	Light = { Colors.LightYellow, Colors.Yellow },
	Darken = { Colors.DarkRed, Colors.Black },
	Luck = { Colors.LightYellow, Colors.Yellow },
	Endure = { Colors.Blue, Colors.DarkBlue },
	Heal = { Colors.LightRed, Colors.Red },
	Calm = { Colors.LightCyan, Colors.Cyan },
	Flow = { Colors.Cyan , Colors.DarkCyan },
	Open = { Colors.LightMagenta , Colors.Magenta },
	Hate = { Colors.White, Colors.Black },
}

function CanCast(itemId)
	return ItemCast[itemId] ~= nil
end

function Cast(x, y, itemId)
	local component = ItemCast[itemId]
	local compName = ItemCastNames[itemId]()
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
				e:Set(comp(), Magic{ colors = CompColors[compName] })
				Diary.Write("You enchant the " .. e[Name].value .. " with the essence of " .. compName .. ".")
			end
		end
	end
end