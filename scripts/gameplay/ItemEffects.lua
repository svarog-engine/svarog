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

local ItemPrefix = {
	diamond = "a ",
	sapphire = "a ",
	obsidian = "an ",
	malachite = "a ",
	lapis_lazuli = "a ",
	onyx = "an ",
	smoky_quartz = "a ",
	garnet = "a ",
	topaz = "a ",
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
	local dungeon = Dungeon
	local compFrom = CompNameToComp

	local x, y = PlayerEntity[Position].x, PlayerEntity[Position].y
	Diary.Write("Grabbing " .. ItemPrefix[itemId] .. ItemNames[itemId] .. ", you cast it to the ground!")
	Diary.Write("A thick, billowing mist rises from the broken jewel.")
	
	local element = ItemCastNames[itemId]
	Diary.Write("It stuns those unaligned with [" .. element .. "].")
	if PlayerEntity[compFrom(element)] == nil then
		local duration = 5
		if PlayerEntity[Endure] then duration = duration - 2 end
		if PlayerEntity[Luck] then duration = duration - 1 end
		PlayerEntity:Set(Paralyzed{ current = duration, maximum = duration - 1 })
	else
		local untouched = true
		for _, e in World:Exec(ECS.Query.All(TempBoon, Timeout)):Iterator() do
			if e[TempBoon].type == element then
				Diary.Write("The mists coil inwards. Your temporary boon solidifies!")
				World:Remove(e)
				untouched = false
			end
		end

		if untouched then
			Diary.Write("You stand untouched by the mists!")
		end
	end

	if element == "Endure" then
		PlayerEntity[Stamina].current = PlayerEntity[Stamina].maximum
	end

	if element == "Calm" then
		PlayerEntity[Tension]:Down(8)
	end

	for i = -5, 5 do
		for j = -5, 5 do
			local nx, ny = x + i, y + j
			if dungeon.floor:Has(nx, ny) and dungeon.passable:Get(nx, ny) and dungeon.playerDistance:Get(nx, ny) <= 5 then
				local t = 6 - dungeon.playerDistance:Get(nx, ny)
				local e = Procgen.MakeObject("Mist", nx, ny, ItemCastNames[itemId], t)
				Fade(e, Colors.Black, Colors.White, 0.1 * t)

				local id = dungeon.floor:ID(nx, ny)
				for _, e in pairs(dungeon.entities[id]) do 
					if e[Creature] ~= nil then
						if e[compFrom(ItemCastNames[itemId])] == nil then
							local duration = 7
							if e[Endure] then duration = duration - 1 end
							if e[Luck] then duration = duration - 1 end
							e:Set(Paralyzed{ current = duration, maximum = duration })

							if element == "Darken" then
								e:Set(Blindness{})
							end
						end
					end

					if element == "Light" and e[Burnable] ~= nil then
						e:Set(Health(Range(10)))
						e:Set(Spread{ chance = 10 })
					end

					if element == "Break" and e[Breakable] ~= nil then
						RemoveEntityFromDungeon(e)
						World:Remove(e)
						Procgen.MakeObject("Dust", nx, ny)
					end

					if element == "Heal" and e[Health] ~= nil then
						e[Health].current = e[Health].current + 5
						if e[Health].current > e[Health].maximum then
							e[Health].current = e[Health].maximum
						end
					end
				end
			end
		end
	end

	return true
end