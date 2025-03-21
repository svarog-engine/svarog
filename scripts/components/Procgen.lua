BumpDiary = ECS.Component{ text = "" }
ScanEntry = ECS.Component{}
Win = ECS.Component{ value = 0 }
InLevel = ECS.Component{ value = 0 }
Name = ECS.Component("")
Burnable = ECS.Component()
Burning = ECS.Component{value = 0.0}
ExplodeFireOnDeath = ECS.Component{}
Unburnable = ECS.Component()
CanMeltGold = ECS.Component()
Dissolvable = ECS.Component()
OldPosition = ECS.Component()

Weapon = ECS.Component()
Amulet = ECS.Component()
Small = ECS.Component()
Paper = ECS.Component()
Shelve = ECS.Component()

Altar = ECS.Component({ type = nil })
Satiated = ECS.Component()

Lifetime = ECS.Component{ value = 5 }
Spread = ECS.Component{ value = 5 }

Key = ECS.Component()
Locked = ECS.Component()

BlockingPassage = ECS.Component()
BlockingSight = ECS.Component()

Breakable = ECS.Component()
CanHaveContent = ECS.Component()

ID = ECS.Component(0)

Templates = {}

IDS = 1

Procgen = {}

function Procgen.MakeObject(what, x, y, ...)
	local dungeon = Dungeon
	local tile = dungeon.floor:Get(x, y)
	local isTF = tile.type == Floor
	local isEN = tile.entity == nil
	local id = dungeon.floor:ID(x, y)
	local es = dungeon.entities[id] or {}
	local isEE = #es == 0
	if isTF and isEE and isEN then
		local e = World:Entity(Position{ x = x, y = y })
		if what == "Goblin" or what == "Hobgob" or what == "Kobold" 
		   or what == "Mimic" or what == "Djinn" or what == "Flamos" 
		   or what == "Illusion" or what == "Ogre" or what == "Rat" then
		   Dungeon.creatureCount = Dungeon.creatureCount + 1
		end

		e:Set(Name { value = what })
		e:Set(ID(IDS))
		e:Set(InLevel{ value = Level })
		IDS = IDS + 1

		if Procgen[what] == nil then
			Svarog.Instance:LogError("PROCGEN: Generator " .. what .. " not found. Check your spelling.")
			return e
		else
			Procgen[what](e, x, y, ...)
		end
		AddEntityToDungeon(x, y, e)
		return e
	else	
		return nil
	end
end

function Procgen.IsFurniture(e)
	e:Set(Breakable{})
	e:Set(BlockingPassage{})
end

function Procgen.IsContainer(e)
	e:Set(CanHaveContent{})
end

function Procgen.CanBreak(e)
	e:Set(Breakable{})
end

function Procgen.IsWooden(e)
	Procgen.CanBreak(e)
	e:Set(Burnable{})
end

function Procgen.IsPaper(e)
	Procgen.IsWooden(e)
	e:Set(Dissolvable{})
end

function Procgen.Glass(e)
	e:Set(Breakable{})
	e:Set(BlockingPassage{})
	e:Set(Glyph{ name = "alarmTrap" }) 
end

---------------------------------------------------------------------------------------------------------

local comps = { 
	"Endure", 
	--"Break", 
	"Luck", 
	"Darken", 
	"Flow", 
	"Heal", 
	--"Calm", 
	"Open", 
	"Light", 
}

function OtherComps(have)
	local t = {}
	for i, h in ipairs(have) do
		t[h] = h
	end

	local cs = {}	
	for i, c in ipairs(comps) do
		if t[c] == nil then table.insert(cs, c) end
	end

	return cs
end

function CompNameToComp(comp)
	if comp == "Endure" then return Endure end
	if comp == "Break" then return Break end
	if comp == "Luck" then return Luck end
	if comp == "Darken" then return Darken end
	if comp == "Flow" then return Flow end
	if comp == "Heal" then return Heal end
	--if comp == "Calm" then return Calm end
	if comp == "Open" then return Open end
	if comp == "Light" then return Light end
	if comp == "Hate" then return Hate end
end

function CompToShardic(comp)
	if comp == "Endure" then return "Endurance" end
	if comp == "Break" then return "Fracture" end
	if comp == "Luck" then return "Luck" end
	if comp == "Darken" then return "Darkness" end
	if comp == "Flow" then return "Flow" end
	if comp == "Heal" then return "Healing" end
	--if comp == "Calm" then return "Calm" end
	if comp == "Open" then return "Openess" end
	if comp == "Light" then return "Light" end
	if comp == "Hate" then return "Hate" end
	print("NOT FOUND: ", comp)
end

function Procgen.Seal(e, x, y)
	e:Set(Item{})
	e:Set(Glyph{ name = "seal" })
	e:Set(BumpDiary{ text = "The enchanted rock of the ROYAL SEAL holds firm."})
end

function Procgen.SatiatedAltar(e, x, y, comp)
	e:Set(Glyph{ name = "altar" })
	e:Set(Item{})
	e:Set(Name{ value = "Altar of " .. CompToShardic(comp) })
	e:Set(Altar{ type = comp })
	e:Set(Satiated{})
	e:Set(Magic{ value = Rand:F01(), colors = CompColors[comp] })
end

function Procgen.SealingMechanism(e, x, y, comp)
	e:Set(Glyph{ name = "hallway" })
	e:Set(Item{})
	e:Set(Name{ value = "Sealing Stone" })
	e:Set(ScanEntry{})
end

function Procgen.Altar(e, x, y, comp)
	e:Set(Glyph{ name = "altar" })
	e:Set(Item{})
	e:Set(Name{ value = "Altar of " .. CompToShardic(comp) })
	e:Set(Altar{ type = comp })
	e:Set(UnMagic{ value = Rand:F01(), colors = CompColors[comp] })
end

function Procgen.Crate(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsWooden(e)
	Procgen.IsContainer(e)
	Procgen.GenerateContents(e, ContentsItems, 3)
	e:Set(Glyph{ name = "crate" })
end

function Procgen.Flame(e, x, y, lifetime, spread)
	e:Set(Burning{ value = Rand:F01() })
	e:Set(Health(Range(lifetime or 20)))
	e:Set(Spread{ chance = spread or 4 })
	e:Set(Glyph{ name = "flame" })
end

function Procgen.Cinders(e, x, y)
	e:Set(Glyph{ name = "cinders" })
	e:Set(Unburnable{})
end

function Procgen.Dust(e, x, y)
	e:Set(Glyph{ name = "dust" })
	e:Set(Unburnable{})
end

function Procgen.Chest(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsContainer(e)
	Procgen.GenerateContents(e, ContentsItems, 10)
	e:Set(Locked{})
	e:Set(Glyph{ name = "chest" })
	Dungeon.numberOfChests = Dungeon.numberOfChests + 1
end

function Procgen.Table(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsWooden(e)
	e:Set(Glyph{ name = "table" })
end

function Procgen.Throne(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsWooden(e)
	e:Set(Glyph{ name = "throne" })
	e:Set(Name("Goblin Throne"))
	e:Set(Item{})
	e:Set(BumpDiary{ text = "The throne of her royal highness, long dead..." })
	e:Set(ScanEntry{})
end

function Procgen.Skeleton(e, x, y)
	e:Set(Glyph{ name = "skeleton" })
	e:Unset(Name)
	e:Set(Name("The Goblin Queen"))
	e:Set(Item{})
	e:Set(BumpDiary{ text = "Died crawling towards the mechanism behind the throne." })
	e:Set(ScanEntry{})
end

function Procgen.Key(e, x, y)
	e:Set(Item{id = "key", quantity = 1}, Key{}, Metallic{})
	e:Set(Glyph{ name = "key" })
end

function Procgen.Dagger(e, x, y)
	e:Set(Item{}, Weapon{}, Small{})
	e:Set(Glyph{ name = "dagger" })
end

function Procgen.Amulet(e, x, y)
	e:Set(Item{}, Amulet{}, Small{})
	e:Set(Glyph{ name = "amulet" })
end

function Procgen.Artifact(e, x, y)
	local options = { "Dagger", "Key", "Book", "Amulet" }
	return Procgen[options[Rand:Range(1, #options)]]
end

function Procgen.Goblin(e, x, y)
	e:Set(
		Creature{}, 
		Sight{ radius = 6 },
		AIMoveTowardsPlayer{ distance = 0, chance = 9 }, 
		Health(Range(2, 2)), 
		BumpAttack { damage = 1 }, 
		Glyph{ name = "goblin" },
		Burnable{},
		Contents{ items = { { itemId = "gold", quantity = 20 } } }
	)
end

function Procgen.Kobold(e, x, y)
	e:Set(
		Creature{}, 
		Sight{ radius = 10 },
		AIMoveTowardsPlayer{ distance = 2, chance = 10 }, 
		Health(Range(1, 1)),
		BumpAttack { damage = 2 }, 
		Glyph{ name = "kobold" },
		Burnable{},
		Contents{ items = { { itemId = "gold", quantity = 10 } } }
	)
end

function Procgen.AlarmTrap(e, x, y)
	e:Set(Invisible(Range(100)), Alarm{})
	e:Set(Glyph{ name = "alarmTrap" })
end

function Procgen.Book(e, x, y, contents)
	Procgen.IsPaper(e)
	e:Set(Item{})
	e:Set(Glyph{ name = "book" })
	e:Set(Text(contents))
end

function Procgen.Shelf(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsWooden(e)
	Procgen.IsContainer(e)
	e:Set(Shelve())
	e:Set(Glyph{ name = "shelf" })
end

function Procgen.Anvil(e, x, y)
	e:Set(BlockingPassage{})
	e:Set(Glyph{ name = "anvil" })
end

function Procgen.Cauldron(e, x, y)
	e:Set(BlockingPassage{})
	e:Set(Glyph{ name = "cauldron" })
	e:Set(CanMeltGold{})
	e:Set(Burning{ value = Rand:F01(), colors = { Colors.LightBlue, Colors.Blue } })
end

function Procgen.Statue(e, x, y)
	e:Set(BlockingPassage{})
	e:Set(Glyph{ name = "statue" })
end

function Procgen.Candle(e, x, y)
	e:Set(BlockingPassage{})
	if Rand:Range(1, 10) < 5 then
		e:Set(Burning{ value = Rand:F01() })
	end
	e:Set(Glyph{ name = "candle" })
end

function Procgen.Furnace(e, x, y)
	e:Set(BlockingPassage{})
	e:Set(Burning{ value = Rand:F01() })
	e:Set(Glyph{ name = "furnace" })
end

function Procgen.Grate(e, x, y)
	e:Set(Metallic{})
	e:Set(Glyph{ name = "grate" .. Rand:Range(1, 3) })
end

function Procgen.Portal(e, x, y, owner, time, comp)
	local time = time or 9
	if time > 9 then time = 9 end
	e:Set(Name("Portal"))
	e:Set(Dependent(owner))
	e:Set(Portal{ challenge = owner, type = comp })
	e:Set(Magic{ value = Rand:F01(), colors = CompColors[comp] })
	e:Set(Timeout{ value = time })
	e:Set(Glyph{ name = "portal" })
end

function Procgen.Rift(e, x, y, owner)
	e:Set(Glyph{ name = "rift" })
	e:Set(Name("Rift"))
	e:Set(Dependent{ value = owner })
	e:Set(Magic{ value = Rand:F01() })
	e:Set(BlockingPassage{})
	e:Set(BlockingSight{})
end

function Procgen.Rat(e, x, y)
	e:Set(
		Creature{}, 
		Sight{ radius = 16 },
		AIMoveTowardsPlayer{ distance = 0, chance = 10 }, 
		AIForcedRandomWalk{},
		Health(Range(1, 1)),
		BumpAttack { damage = 1 },
		Luck{ chance = 3 },
		Glyph{ name = "rat" }
	)
end

function Procgen.Hobgob(e, x, y)
	e:Set(
		Creature{}, 
		Endure{},
		Sight{ radius = 8 },
		Magic{ value = Rand:F01(), colors = CompColors["Endure"] },
		AIKeepDistanceFromPlayer{ distance = 5, chance = 10 },
		AISpawnWhenDistantFromPlayer{ min = 4, max = 6, chance = 4, what = "Rat" },
		Health(Range(2, 2)), 
		BumpAttack { damage = 1 }, 
		Glyph{ name = "hobgob" },
		Contents{ items = { { itemId = "gold", quantity = 100 } } }
	)
end

function Procgen.Mimic(e, x, y)
	e:Set(
		Creature{}, 
		Endure{},
		Sight{ radius = 15 },
		Magic{ value = Rand:F01(), colors = CompColors["Endure"] },
		AIAttackIfStandingNextTo{}, 
		AIMoveTowardsPlayer{ distance = 10, chance = 3 }, 
		Health(Range(1)), 
		BumpAttack { damage = 3 }, 
		Glyph{ name = "chest" },
		Burnable{},
		Contents{ items = { { itemId = "gold", quantity = 50 } } }
	)
end

function Procgen.Ogre(e, x, y)
	e:Set(
		Creature{}, 
		Break{},
		Sight{ radius = 10 },
		Magic{ value = Rand:F01(), colors = CompColors["Open"] },
		AIBreakThroughToPlayer{ chance = 5, distance = 9 },
		Health(Range(3)), 
		BumpAttack { damage = 3 }, 
		Glyph{ name = "ogre" },
		Contents{ items = { { itemId = "gold", quantity = 150 } } }
	)
end

function Procgen.Flamos(e, x, y)
	e:Set(
		Creature{}, 
		Break{},
		Sight{ radius = 10 },
		OldPosition{},
		ExplodeFireOnDeath{},
		Magic{ value = Rand:F01(), colors = CompColors["Light"] },
		AIKeepDistanceFromPlayer{ distance = 1, chance = 9 },
		AIRest{ chance = 1 },
		Health(Range(1)),
		Burning{},
		Glyph{ name = "sphere" },
		Contents{ items = { { itemId = "gold", quantity = 100 } } }
	)
end

function Procgen.Djinn(e, x, y)
	e:Set(
		Creature{},
		Sight{ radius = 10 },
		OldPosition{},
		ExplodeFireOnDeath{},
		Magic{ value = Rand:F01(), colors = CompColors["Open"] },
		AIMoveTowardsPlayer{ distance = 0, chance = 9 },
		Health(Range(20)),
		Burning{},
		Darken{},
		Spread{ chance = 4 },
		Glyph{ name = "djinn" },
		Contents{ items = { { itemId = "gold", quantity = 80 } } }
	)
end

function Procgen.Illusion(e, x, y)
	e:Set(
		Creature{},
		Name{ value = "Illusion" },
		Sight{ radius = 5 },
		Magic{ value = Rand:F01(), colors = CompColors["Flow"] },
		AIForcedRandomWalk{},
		AIAttackIfStandingNextTo{},
		AISpawnWhenDistantFromPlayer{ min = 3, max = 3, chance = 9, what = "Illusion" },
		Health(Range(4)),
		Glyph{ name = "restless" },
		Contents{ items = { { itemId = "gold", quantity = 1 } } }
	)
end

function Procgen.GelatinousCube(e, x, y)
	e:Set(
		Creature{},
		Name{ value = "Gelatinous Cube" },
		Sight{ radius = 20 },
		Magic{ value = Rand:F01(), colors = CompColors["Flow"] },
		AIMoveTowardsPlayer{ distance = 0, chance = 6 },
		AIBreakThroughToPlayer{ chance = 4, distance = 9 },
		Health(Range(20)),
		Glyph{ name = "gelly" },
		Contents{ items = {} },
		SplitOnHit{ what = "GelatinousCube" },
		Contents{ items = { { itemId = "gold", quantity = Rand:Range(1, 20) * 10 } } }
	)
end

function Procgen.Mist(e, x, y, type, duration)
	e:Set(
		Name{ value = "Mist" },
		Glyph{ name = "mist" },
		Magic{ value = Rand:F01(), colors = CompColors[type] },
		Timeout{ value = duration },
		Mist{ type = type }
	)
end


--Monsters["Endure"] = { "Hobgob", "Mimic" }
--Monsters["Luck"] = { "PlagueRats", "Vampire" }
--Monsters["Darken"] = { "Shade", "Wraith" }
--Monsters["Flow"] = { "Illusion", "GelatinousCube" }
--Monsters["Heal"] = { "Kobold", "Phantasm" }
--Monsters["Calm"] = { "Banshee", "Nightmare" }
--Monsters["Open"] = { "Flamos", "Ogre" }
--Monsters["Light"] = { "Flamos", "Djinn" }

function Procgen.GenerateContents(e, itemList, chance)
	local itemSet = {}

	if Chances[chance]:MakeGuess() then
		repeat
			local item, quantity = itemList[Rand:Range(1, #itemList)], Rand:Range(1, 3)
			if itemSet[item] == nil then
				itemSet[item] = quantity
			else
				itemSet[item] = itemSet[item] + quantity
			end
		until not Chances[5]:MakeGuess()
	end
	
	local items = {}
	for item, quantity in pairs(itemSet) do
		table.insert(items, { itemId = item, quantity = quantity })
	end
    e:Set(Contents { items = items })
end

function Templates.LibraryRoom(cx, cy)
	if Dungeon.wallDistances:Get(cx, cy) >= 2 then
		local room = DistanceMap:From(Dungeon.floor, { { cx, cy } }, 0, 7)
		room:AddCondition(function(map, x, y) return Dungeon.wallDistances:Has(x, y) and Dungeon.wallDistances:Get(x, y) >= 2 end)
		room:Flood()

		local w, h = Dungeon.floor:Size()
		for i = 1, w do
			for j = 1, h do
				Dungeon.zones:Set(i, j, -1)
				if Dungeon.floor:Get(i, j).type == Floor then
					if i % 2 == 0 and j % 2 == 0 then
						if room:Has(i, j) and room:Get(i, j) >= 0 and room:Get(i, j) < 10 then
							if Chances[5]:MakeGuess() then
								Procgen.MakeObject("Shelf", i, j)
							end
						end
					end
				end
			end
		end
	end
end

function Templates.StoreRoom(cx, cy)
	if Dungeon.wallDistances:Get(cx, cy) >= 2 then
		local room = DistanceMap:From(Dungeon.floor, { { cx, cy } }, 0, 7)
		room:AddCondition(function(map, x, y) return Dungeon.wallDistances:Has(x, y) and Dungeon.wallDistances:Get(x, y) >= 2 end)
		room:Flood()

		local w, h = Dungeon.floor:Size()
		for i = 1, w do
			for j = 1, h do
				Dungeon.zones:Set(i, j, -1)
				if Dungeon.floor:Get(i, j).type == Floor then
					if i % 2 == 0 and j % 2 == 0 and Chances[2]:MakeGuess() then
						if room:Has(i, j) and room:Get(i, j) >= 0 and room:Get(i, j) < 10 then
							if Chances[5]:MakeGuess() then
								Procgen.MakeObject("Crate", i, j)
							end
						end
					end
				end
			end
		end
	end
end


local function MakeTemplate(name, w, h, template, ...)
	local argz = { ... }
	local w = w or 0
	local h = h or 0
	local template = template or ""
	Templates[name] = function(x, y)
		local wall = Dungeon.wallDistances:Get(x, y)
		if wall < w or wall < h then
			return
		end

		local w2, h2 = math.floor(w / 2), math.floor(h / 2)
		for i = 1, w do
			for j = 1, h do
				local xx, yy = x + i - w2, y + j - h2
				if Dungeon.floor:Has(xx, yy) and Dungeon.floor:Get(xx, yy).type == Floor and Dungeon.zones:Get(xx, yy) >= 0 then
					local index = j * w + i
					local t = string.sub(template, index, index)
					Dungeon.zones:Set(xx, yy, -1)
					if t ~= "." and t ~= " " and t ~= "\n" and t ~= "\t" then
						local num = tonumber(t)
						if num ~= nil then
							local spots = argz[num]
							local spot = spots[Rand:Range(1, #spots)]
							if spot ~= nil then 
								Procgen.MakeObject(spot, xx, yy)
							end
						end
					end
				end
			end
		end
	end
end


MakeTemplate("common1", 3, 3,
[[
.23
.1.
...
]], { nil, nil, nil, nil, nil, nil, "Key", "Goblin" }, { nil, "Crate", "Table", "Crate" }, { nil, nil, "Table", "Crate" })

MakeTemplate("common2", 4, 3,
[[
.1..
....
1.1.
]], { nil, nil, "Crate", "Chest", "Chest" }
)

MakeTemplate("warehouse1", 5, 3,
[[
.1.1.
21.12
21212
]], { nil, "Crate", "Crate", "Crate", "Crate" }, { nil, "Goblin" }
)

MakeTemplate("warehouse2", 4, 4,
[[
1221
1...
1..1
1112
]], { "Crate", "Table", "Shelf" }, { "Goblin", "Crate", "Goblin" })

MakeTemplate("warehouse3", 4, 4,
[[
1121
...2
1..1
2.11
]], { "Crate", "Table", "Shelf" }, { nil, "Goblin", "Chest", "Chest", "Crate" })

MakeTemplate("library1", 3, 3,
[[
..2
.1.
...
]], { "Shelf" }, { "Goblin" })

MakeTemplate("library2", 3, 3,
[[
1..
.22
..1
]], { "Shelf" }, { nil, "Goblin" })

MakeTemplate("library3", 5, 3,
[[
1.221
.....
1...1
]], { "Shelf" },  { nil, "Goblin", "Kobold" })

MakeTemplate("exhibit1", 5, 5,
[[
.....
.....
..1..
..2..
.....
]], { "Artifact" }, {"Goblin", "Kobold", "Goblin", "Kobold", "Hobgob" })

MakeTemplate("exhibit2", 3, 3,
[[
..2
.1.
...
]], { "Artifact", "Statue" }, { nil, nil, nil, nil, nil, "Key", "Amulet" })

MakeTemplate("workshop1", 5, 5,
[[
.....
.111.
..23.
.4...
.....
]], { nil, "Shelf", "Shelf", "Shelf", "Crate" }, { "Anvil" }, { nil, "Table" }, { "Kobold", "Goblin" })

MakeTemplate("workshop2", 3, 3,
[[
131
.21
...
]], { nil, "Shelf", "Shelf", "Shelf", "Crate" }, { "Anvil", "Cauldron" }, { "Goblin", "Kobold" })

MakeTemplate("shrine1", 3, 3,
[[
1..
.2.
..1
]], { "Candle" }, { "Goblin", "Statue" })

MakeTemplate("shrine1", 5, 3,
[[
1...1
1.2.1
1...1
]], { nil, "Candle" }, { "Goblin", "Hobgob" })

MakeTemplate("shrine2", 6, 6,
[[
13.1.
3...3
.124.
3...1
.3.1.
]], { "Candle" }, { "Statue" }, { nil, nil, nil, nil, nil, "Book", "Candle" }, { "Kobold", "Hobgob" })

MakeTemplate("forge1", 5, 5,
[[
33333
3.1.3
32332
3.1.3
32332
]], { "Furnace" }, { nil, "Furnace" }, { "Grate", "Kobold" })

MakeTemplate("forge2", 3, 3,
[[
333
213
332
]], { "Furnace" }, { nil, "Furnace" }, { "Grate", nil })

Rooms = {}
Rooms[Open] = { "StoreRoom", "common1", "common2", "warehouse1", "warehouse2" }
Rooms[Uncover] = { "LibraryRoom", "exhibit1", "exhibit2" }
Rooms[Enlarge] = { "workshop1", "workshop2", "shrine1", "shrine2" }
Rooms[Flow] = { "StoreRoom", "common1", "common2" }
--Rooms[Calm] = { "common1", "common2", "shrine1" }
Rooms[Rage] = { "forge1", "forge2", "warehouse1", "warehouse2", "common1" }
Rooms[Yearn] = { "exhibit1", "exhibit2", "shrine2" }
Rooms[Discover] = { "StoreRoom", "library2", "workshop2", "common1", "common2" }
Rooms[Heal] = { "common1", "common2" } --market, medic
Rooms[Endure] = { "workshop1", "workshop2" } -- training room
Rooms[Luck] = { "StoreRoom", "common1", "common2" } -- market
Rooms[Fade] = { "warehouse1", "common1", "common2" }

ContentsItems = { "diamond", "topaz", "obsidian", "malachite", "lapis_lazuli", "onyx", --"smoky_quartz",
	"sapphire", "garnet", "ash", "rosebud", "blackthorn", "willow", "sage", "foxglove", "mandrake" }

Monsters = {}
Monsters["Endure"] = { "Hobgob", "Mimic" }
Monsters["Luck"] = { "Goblin", "Kobold" }
Monsters["Darken"] = { "Kobold", "Kobold" }
Monsters["Flow"] = { "Illusion", "GelatinousCube" }
Monsters["Heal"] = { "Hobgob", "Phantasm" }
--Monsters["Calm"] = { "Banshee", "Nightmare" }
Monsters["Open"] = { "Flamos", "Ogre" }
Monsters["Light"] = { "Flamos", "Djinn" }
Monsters["Hate"] = { "Flamos", "Djinn", "Ogre", "Kobold", "Hobgob", "Mimic", "Goblin" }

Messages = { 
	"You read: DIAMONDS serve the OPEN sky",
	"You read: Ogres and Flamosi form an OPEN alliance...",
	"You read: SAPPHIRE splits LIGHT in two",
	"You read: Roses for silence, OBSIDIAN for DARKNESS",
	"You read: MALACHITE is what makes good fortune",
	"You read: HOBGOBs are immune to SKYSTONES.",
	"You read: Beware DJINN, they blaze ALIGHT...",
	"You read: SKYSTONES can ENDURE forever",
	"You read: ONYX figures into HEALING",
	--"You read: A CALMing influence, QUARTZ is...",
	"You read: GARNETs for a steady FLOW.",
	"You read: TOPAZ to LIGHT the darkness.",
	"You read: Herbs give, stones solidify."
}

Messages.index = 1

function GetNextMessage()
	local message = Messages[Messages.index]
	Messages.index = Messages.index + 1

	if Messages.index > #Messages then
		Messages.index = 1
	end

	return message
end