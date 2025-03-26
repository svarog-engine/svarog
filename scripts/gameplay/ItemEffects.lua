ItemConsume = { 
	ash = "Open",
	rosebud = "Light",
	blackthorn = "Darken",
	willow = "Luck",
	sage = "Endure",
	foxglove = "Heal",
	mandrake = "Luck",
}

local ItemCastNames = {
	diamond = "Break",
	sapphire = "Light",
	obsidian = "Darken",
	malachite = "Luck",
	lapis_lazuli = "Endure",
	onyx = "Heal",
	--smoky_quartz = "Calm",
	garnet = "Flow",
	topaz = "Open",
}

local sqrt = math.sqrt

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
		PlayerKnowledge[itemId] = name
		PlayerEntity[Tension]:Down(8)
	else
		Diary.Write("Consuming " .. itemId .. " gives you a sliver of " .. string.upper(name) .. ".")
		PlayerKnowledge[itemId] = name
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
	--smoky_quartz = "Quartz",
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
	--smoky_quartz = "a ",
	garnet = "a ",
	topaz = "a ",
}

CompColors = {
	Break = { Colors.LightBlue, Colors.Blue },
	Light = { Colors.LightYellow, Colors.Yellow },
	Darken = { Colors.DarkRed, Colors.Black },
	Luck = { Colors.Yellow, Colors.LightGreen },
	Endure = { Colors.Blue, Colors.DarkBlue },
	Heal = { Colors.LightRed, Colors.Red },
	--Calm = { Colors.LightCyan, Colors.Cyan },
	Flow = { Colors.Green , Colors.DarkCyan },
	Open = { Colors.LightMagenta , Colors.Magenta },
	Hate = { Colors.Magenta, Colors.DarkRed },
}

function CanCast(itemId)
	return ItemCastNames[itemId] ~= nil
end

local function Distance(x1, y1, x2, y2)
	local dx, dy = x1 - x2, y1 - y2
	return sqrt(dx * dx + dy * dy)
end

function Cast(itemId)
	local dungeon = Dungeon
	local compFrom = CompNameToComp

	local x, y = PlayerEntity[Position].x, PlayerEntity[Position].y
	Diary.Write("Grabbing " .. ItemPrefix[itemId] .. ItemNames[itemId] .. ", you cast it to the ground!")
	Diary.Write("A thick, billowing mist rises from the broken jewel.")
	
	local element = ItemCastNames[itemId]
	Diary.Write("It stuns those unaligned with [" .. element .. "].")
	PlayerKnowledge[itemId] = element
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

	--if element == "Calm" then
--		PlayerEntity[Tension]:Down(8)
	--end

	for i = -5, 5 do
		for j = -5, 5 do
			local nx, ny = x + i, y + j
			if dungeon.floor:Has(nx, ny) and Distance(x, y, nx, ny) <= 5 then
				local t = 6 - Distance(x, y, nx, ny)
				
				local id = dungeon.floor:ID(nx, ny)
				for _, e in ipairs(dungeon.entities[id] or {}) do
					if element == "Darken" then
						e:Unset(Burning)
						e:Unset(Spread)
						e:Unset(Burnable)
						e:Unset(Magic)
						e:Unset(ExplodeFireOnDeath)
					end

					if e[Creature] ~= nil then
						if e[compFrom(ItemCastNames[itemId])] == nil then
							local duration = 10
							if e[Endure] then duration = duration - 1 end
							if e[Luck] then duration = duration - 1 end
							e:Set(Paralyzed{ current = duration, maximum = duration })

							if element == "Darken" then
								e:Set(Blindness{})
							end
						end
					end

					if element == "Light" and e[Burnable] ~= nil then
						if e[Creature] ~= nil then
							Diary.Write("The " .. e[Name].value .. " is set ablaze!")
						end
						e:Set(Burning{})
						e:Set(Health(Range(10)))
						e:Set(Spread{ chance = 6 })
					end

					if element == "Break" and e[Breakable] ~= nil then
						if e[Creature] ~= nil then
							Diary.Write("The " .. e[Name].value .. " shrieks and breaks apart!")
						end
						RemoveEntityFromDungeon(e)
						World:Remove(e)
					end

					if element == "Open" and e[Locked] ~= nil then
						e:Unset(Locked)
					end

					if element == "Open" and e[Contents] ~= nil then
						if #e[Contents].items == 0 then
							e:Unset(Contents)
							e[Glyph].name = e[Glyph].name .. "_empty"
						end
					end

					if element == "Heal" and e[Health] ~= nil then
						e[Health].current = e[Health].current + 5
						if e[Health].current > e[Health].maximum then
							e[Health].current = e[Health].maximum
						end
					end
				end

				local e = Procgen.MakeObject("Mist", nx, ny, ItemCastNames[itemId], t)
				Fade(e, Colors.Black, Colors.White, 0.1 * t)
			end
		end
	end

	return true
end