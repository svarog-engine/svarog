ItemConsume = { 
	ash = "Break",
	rosebud = "Light",
	blackthorn = "Darken",
	willow = "Luck",
	sage = "Endure",
	foxglove = "Heal",
	mandrake = "Luck",
}

function CanConsume(itemId)
	return ItemConsume[itemId] ~= nil
end

function Consume(itemId)
	Diary.Write("You consume " .. itemId .. ".")
	local name = ItemConsume[itemId]
	if name == nil then
		return
	end

	local comp = CompNameToComp(name)
	if PlayerEntity[comp] ~= nil then
		Diary.Write("The taste of " .. itemId .. " relaxes you greatly.")
		PlayerEntity[Tension]:Down(8)
	else
		Diary.Write("Consuming " .. itemId .. " gives you a sliver of " .. string.upper(name) .. ".")
		PlayerEntity:Set((comp){ level = 1, chance = 5 })
		table.insert(PlayerEntity[Boons].value, name)
		World:Entity(TempBoon{ type = name }, Timeout{ value = 10 })
	end

	return true
end

local ItemNames = {
	diamond = "Diamond",
	sapphire = "Sapphire",
	obsidian = "Obsidian",
	malachite = "Malachite",
	lapis_lazuli = "Skystone",
	onyx = "Onyx",
	smoky_quartz = "Quartz",
	garnet = "Garnet",
	topaz = "Topaz",
}

local ItemCastNames = {
	diamond = "Break",
	sapphire = "Light",
	obsidian = "Darken",
	malachite = "Luck",
	lapis_lazuli = "Endure",
	onyx = "Heal",
	smoky_quartz = "Calm",
	garnet = "Flow",
	topaz = "Open",
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
	return ItemCastNames[itemId] ~= nil
end

function Cast(itemId)
	Diary.Write("Grabbing " .. ItemNames[itemId] .. ", you cast it to the ground!")
	
	return true
end