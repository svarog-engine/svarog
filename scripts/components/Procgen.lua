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
	if tile ~= nil then
		local isTF = tile.type == Floor
		local isEN = tile.entity == nil
		local id = dungeon.floor:ID(x, y)
		local es = dungeon.entities[id] or {}
		local isEE = #es == 0
		if isTF and (isEE or what == "RoyalSeal") and isEN then
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
			--print("CANT MAKE: ", what, isTF, isEE, isEN)
			return nil
		end
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
function Procgen.RoyalSeal(e, x, y)
	e:Set(Item{})
	e:Set(Glyph{ name = "seal" })
	e:Set(Name{ value = "Royal Seal" })
	e:Set(ScanEntry{})
	e:Set(RoyalSeal{})
	--e:Set(UnMagic{ value = Rand:F01(), colors = { Colors.Gray, Colors.Black } })
end

function Procgen.Seal(e, x, y)
	e:Set(Item{})
	e:Set(Glyph{ name = "seal" })
	e:Set(Name{ value = "Royal Seal" })
	e:Set(BumpDiary{ text = "The enchanted rock of the ROYAL SEAL holds firm."})
	e:Set(UnMagic{ value = Rand:F01(), colors = { Colors.Gray, Colors.Black } })
end

function Procgen.Pillar(e, x, y)
	e:Set(Item{})
	e:Set(Glyph{ name = "pillar" })
	e:Set(BlockingPassage{})
	e:Set(BlockingSight{})
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
	e:Set(CanSeal{})
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
	if Dungeon.numberOfChests < 1 then
		Procgen.IsFurniture(e)
		Procgen.IsContainer(e)
		local index = Procgen.GeneratePairedContents(e)
		e:Set(Locked{})
		e:Set(Glyph{ name = "chest" })
		e:Set(Magic{ value = Rand:F01(), colors = pairColors[index] })
		Dungeon.numberOfChests = Dungeon.numberOfChests + 1
	else
		Procgen.Crate(e, x, y)
	end
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
		Contents{ items = { { itemId = "gold", quantity = 2 } } }
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
		Darken{},
		Contents{ items = { { itemId = "gold", quantity = 5 } } }
	)
end

function Procgen.Phantasm(e, x, y)
	e:Set(
		Creature{}, 
		Sight{ radius = 10 },
		AIMoveTowardsPlayer{ ifLessThanOrEqual = 2, distance = 0, chance = 5 }, 
		AIMoveTowardsPlayerThroughShadows{ chance = 10 },
		Health(Range(6, 6)),
		BumpAttack { damage = 3 }, 
		Glyph{ name = "phantasm" },
		Heal{ chance = 9 },
		Contents{ items = { { itemId = "gold", quantity = 300 } } }
	)
end

function Procgen.AltarTrap(e, x, y, callback)
	e:Set(Glyph{ name = "back_semi" }, Alarm{ callback = callback })
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

local numberOfCauldrons = 0
function Procgen.Cauldron(e, x, y)
	if numberOfCauldrons < 1 then
		e:Set(BlockingPassage{})
		e:Set(Glyph{ name = "cauldron" })
		e:Set(CanMeltGold{}, Item{})
		e:Set(Burning{ value = Rand:F01(), colors = { Colors.LightGreen, Colors.Green } })
		numberOfCauldrons = numberOfCauldrons + 1
	end
end

Goblins = { 
	"Borkle",   "Marrow",   "Tododon",   "Sparkmack",   "Svish",   "Mogglewog",   "Bendigo",   "Jare",   "Peacho",   "Lock",   
	"Shock",   "Barrel",   "Snik",   "Snak",   "Gordo",   "Nipmonger",   "Riddle",   "Spip",   "Kaa",   "Bonegrundle",   "Yaxmax",   
	"Tamborine",   "Riggity",   "Fishspleen",   "Bladder Dan",   "Mumblemorg",   "Piss Jar",   "Kettle",   "Gnogin",   "Eee",   
	"Rattrap",   "Bigsmalls",   "Pork",   "Fwip",   "Gong",   "Zaza",   "Meeg",   "Meeg Two",   "Meeg Three",   "Spud",   "Uvano",   
	"Pingpang",   "Bowel",   "Ham",   "Gritgrash",   "Countbean",   "Sap Sam",   "Leek Leek",   "Bwob",   "Parsnip Jr.",   "Parsnip Sr,",   
	"Fat Cat",   "Eyemasher",   "Quiss",   "Wawa",   "Spork",   "Turnaround",   "Barfknees",   "KnifeyMcFingers",   "Cowshout",   "Spank",   
	"Stumpy",   "Backwater",   "Crowlaw",   "Clockwind",   "Burtlan",   "Smee",   "Macintosh",   "Sexpants",   "Ol' Crabapple",   "Muckman",   
	"Dirtwallow",   "Crooknose",   "Beetlepocket",   "Sticky",   "Vraaz",   "Vick",   "Brackish",   "Pondjohn",   "Waxmuncher",   "Wicklicker",   
	"Candleear",   "Grimm",   "Portho",   "Odo",   "Fleshgutter",   "Slugsnatcher",   "Milksalt",   "Stewslosh",   "Cast Iron",   "Dutch",   
	"Squirrelskinner",   "Froggrope",   "Topsyturvy",   "Lardmouth",   "Thighflayer",   "Sinew",   "Hypotenoose",   "Gallow",   "Boblin", 
}

Attr = {
	"Great",
	"Destined",
	"Auld",
	"Holy",
	"Our",
	"Auld",
	"Holy",
	"Beloved",
	"Auld",
	"Holy",
	"Our",
	"Troubled",
}

Jobs = {
	"Survivor",
	"Healer",
	"Miner",
	"Builder",
	"Librarian",
	"Inventor",
	"Warrior",
	"Seamstress",
	"Queen",
}

BookNames = {
	"Grimoire",
	"Fables",
	"Fables",
	"Histories",
	"Poems",
	"Poems",
	"Bundle of Scripts",
	"Scribbles",
	"Scribbles",
	"Scribbles",
	"Scribbles",
	"Mad Notes",
	"Cyphers",
	"Psychoanalysis",
	"KOBOL Handbook",
	"Arcane Treaties",
}

function Procgen.Statue(e, x, y)
	e:Set(BlockingPassage{})
	e:Set(Glyph{ name = "statue" })
	e:Set(Item{})
	local text = "Statue of " .. Goblins[Rand:Range(1, #Goblins)] .. ", " .. Attr[Rand:Range(1, #Attr)] .. " " .. Jobs[Rand:Range(1, #Jobs)]
	e:Set(Name(text))
	e:Set(BumpDiary{ text = text })
end

function Procgen.Candle(e, x, y)
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
		Magic{ value = Rand:F01(), colors = { CompColors["Endure"][1], Colors.Black } },
		AIKeepDistanceFromPlayer{ distance = 5, chance = 10 },
		AISpawnWhenDistantFromPlayer{ min = 4, max = 6, chance = 4, what = "Rat" },
		Health(Range(2, 2)), 
		BumpAttack { damage = 1 }, 
		Glyph{ name = "hobgob" },
		Contents{ items = { { itemId = "gold", quantity = 20 } } }
	)
end

function Procgen.Mimic(e, x, y)
	e:Set(
		Creature{}, 
		Endure{},
		Sight{ radius = 15 },
		Magic{ value = Rand:F01(), colors = { CompColors["Endure"][1], Colors.Black } },
		AIAttackIfStandingNextTo{}, 
		Health(Range(4)), 
		BumpAttack { damage = 3 }, 
		Glyph{ name = "chest" },
		Burnable{},
		Breakable{},
		Contents{ items = { { itemId = "gold", quantity = 50 } } }
	)
end

function Procgen.Ogre(e, x, y)
	e:Set(
		Creature{}, 
		Break{},
		Sight{ radius = 10 },
		Magic{ value = Rand:F01(), colors = CompColors["Open"] },
		AIMoveTowardsPlayer{ distance = 0, chance = 5 },
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
		Health(Range(5)),
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
		Contents{ items = { { itemId = "gold", quantity = 200 } } }
	)
end

function Procgen.Illusion(e, x, y)
	e:Set(
		Creature{},
		Name{ value = "Illusion" },
		Sight{ radius = 5 },
		Magic{ value = Rand:F01(), colors = CompColors["Flow"] },
		BumpAttack{ damage = 1 },
		AIForcedRandomWalk{},
		AISpawnWhenDistantFromPlayer{ min = 1, max = 3, chance = 5, what = "Illusion" },
		Lifetime{ value = Rand:Range(5, 10) },
		Health(Range(2)),
		Glyph{ name = "restless" },
		Contents{ items = { { itemId = "gold", quantity = 25 } } }
	)
end

function Procgen.Sacrifice(e, x, y)
	e:Set(
		Creature{},
		Name{ value = "Sacrifice" },
		Sight{ radius = 15 },
		BumpAttack { damage = 2 },
		AIForcedRandomWalk{},
		AIMoveTowardsPlayer{ distance = 0, chance = 9 },
		AISpawnWhenDistantFromPlayer{ min = 9, max = 12, chance = 2, what = "Goblin" },
		Health(Range(10)),
		Glyph{ name = "sacrifice" },
		Hate{}
	)

	local i = 0
	for _, c in ipairs(comps) do
		if Chances[4]:MakeGuess() then
			i = i + 1
			e:Set(CompNameToComp(c))
			if i == 1 then
				e:Set(Magic{ value = Rand:F01(), colors = { CompColors[c][1], Colors.Black } })
			end
		end
	end
end

function Procgen.Ooze(e, x, y)
	e:Set(
		Creature{},
		Name{ value = "Ooze" },
		Sight{ radius = 20 },
		Magic{ value = Rand:F01(), colors = CompColors["Flow"] },
		AIMoveTowardsPlayer{ distance = 0, chance = 6 },
		AIBreakThroughToPlayer{ chance = 4, distance = 9 },
		Health(Range(20)),
		Glyph{ name = "gelly" },
		Contents{ items = {} },
		SplitOnHit{ what = "Ooze" },
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

pairColors = {
	{ Colors.LightBlue, Colors.Blue }, --Break
	{ Colors.LightMagenta , Colors.Magenta }, --Open
	{ Colors.LightYellow, Colors.Yellow }, --Light
	{ Colors.DarkRed, Colors.Black }, --Darken
	{ Colors.Yellow, Colors.LightGreen }, --Luck
	{ Colors.Blue, Colors.DarkBlue }, --Endure
	{ Colors.LightRed, Colors.Red }, --Heal
	{ Colors.Yellow, Colors.LightGreen }, --Luck
	{ Colors.Black , Colors.DarkCyan }, --Flow
	{ Colors.Black, Colors.DarkRed }, --Hate
}

function Procgen.GeneratePairedContents(e)
	local paired = {
		{ "diamond", },					-- Break
		{ "ash", "topaz" },				-- Open
		{ "rosebud", "sapphire" },		-- Light
		{ "blackthorn", "obsidian" },	-- Darken
		{ "willow", "malachite" },		-- Luck
		{ "sage", "lapis_lazuli" },		-- Endure
		{ "foxglove", "onyx" },			-- Heal
		{ "mandrake", "malachite" },	-- Luck
		{ "garnet" },					-- Flow
	}

	local itemSet = {}

	local index = Rand:Range(1, #paired)
	local pair = paired[index]
	local items = {}
	for _, item in ipairs(pair) do
		table.insert(items, { itemId = item, quantity = 1 })
	end
    e:Set(Contents { items = items })
	return index
end

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
	if Dungeon.wallDistances:Get(cx, cy) >= 2 and Dungeon.zones:Get(cx, cy) >= 0 then
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
							elseif Chances[1]:MakeGuess() then
								Procgen.MakeObject("Cauldron", i, j)
							end
						end
					end
				end
			end
		end
	end
end

function Templates.StoreRoom(cx, cy)
	if Dungeon.wallDistances:Get(cx, cy) >= 2 and Dungeon.zones:Get(cx, cy) >= 0 then
		local room = DistanceMap:From(Dungeon.floor, { { cx, cy } }, 0, 5)
		room:AddCondition(function(map, x, y) return Dungeon.wallDistances:Has(x, y) and Dungeon.wallDistances:Get(x, y) >= 2 end)
		room:Flood()

		local w, h = Dungeon.floor:Size()
		for i = 1, w do
			for j = 1, h do
				Dungeon.zones:Set(i, j, -1)
				if Dungeon.floor:Get(i, j).type == Floor then
					if i % 2 == 0 and j % 2 == 0 and Chances[2]:MakeGuess() then
						if room:Has(i, j) and room:Get(i, j) >= 0 and room:Get(i, j) < 10 then
							if Chances[4]:MakeGuess() then
								Procgen.MakeObject("Crate", i, j)
							elseif Chances[2]:MakeGuess() then
								Procgen.MakeObject("Chest", i, j)
							elseif Chances[5]:MakeGuess() then
								Procgen.MakeObject("Cauldron", i, j)
							end
						end
					end
				end
			end
		end
	end
end

function Templates.ShrineRoom(cx, cy)
	local oldDist = Dungeon.wallDistances:Get(cx, cy)
	local newDist = oldDist
	
	local x, y = cx, cy
	local attempts = 100
	while attempts > 0 do
		attempts = attempts - 1
		local startDist = oldDist
		for _, t in ipairs(Dungeon.wallDistances:Neighbors(x, y)) do
			newDist = Dungeon.wallDistances:Get(t.x, t.y)
			if newDist > oldDist and Dungeon.zones:Get(t.x, t.y) >= 0 then
				oldDist = newDist
				x, y = t.x, t.y
			end
		end

		if startDist == newDist then
			break
		end
	end

	if newDist >= 5 then
		cx, cy = x, y
		local c = Geometry.MakeCircle(x, y, newDist - 1)
		local bound = Geometry.Boundary(c).Points:GetEnumerator()
		local surf = Geometry.Surface(c).Points:GetEnumerator()

		local i = 0
		while surf:MoveNext() do
			local x, y = surf.Current.X, surf.Current.Y
			if Dungeon.zones:Get(x, y) >= 0 then
				Dungeon.zones:Set(x, y, -1)
				local tile = Dungeon.floor:Get(x, y)
				tile.type = Floor
				if tile.entity ~= nil then
					RemoveEntityFromDungeon(tile.entity)
					tile.entity = nil
				end
				i = i + 1
			else
				return
			end
		end

		if i > 0 then
			print("SHRINE DONE IN " .. tostring(i) .. " STEPS")

			while bound:MoveNext() do
				local x, y = bound.Current.X, bound.Current.Y
				if Chances[5]:MakeGuess() then
					Procgen.MakeObject("Candle", x, y)
				end
			end

			Procgen.MakeObject("Statue", cx, cy)
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
]], { nil, nil, nil, nil, nil, nil, "Key", "Goblin" }, { nil, "Crate", "Table", "Chest" }, { nil, nil, "Table", "Crate" })

MakeTemplate("common2", 4, 3,
[[
.1..
....
1.1.
]], { nil, nil, "Crate", "Chest", "Cauldron" }
)

MakeTemplate("warehouse1", 5, 3,
[[
.1.1.
21.12
21212
]], { nil, "Crate", "Crate", "Crate", "Cauldron" }, { nil, "Goblin" }
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
]], { nil, "Shelf", "Shelf", "Chest", "Crate" }, { "Anvil" }, { nil, "Table" }, { "Kobold", "Goblin" })

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
]], { "Candle" }, { "Statue" }, { nil, nil, nil, nil, nil, "Book", "Candle", "Chest" }, { "Kobold", "Hobgob" })

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
Rooms[Open] = { "StorageRoom", "common1", "common2", "warehouse1", "warehouse2" }
Rooms[Uncover] = { "LibraryRoom", "exhibit1", "exhibit2" }
Rooms[Enlarge] = { "workshop1", "workshop2", "shrine1", "shrine2" }
Rooms[Flow] = { "ShrineRoom", "StoreRoom", "common1", "common2" }
--Rooms[Calm] = { "common1", "common2", "shrine1" }
Rooms[Rage] = { "forge1", "forge2", "warehouse1", "warehouse2", "common1" }
Rooms[Yearn] = { "ShrineRoom" }
Rooms[Discover] = { "StoreRoom", "library2", "workshop2", "common1", "common2" }
Rooms[Heal] = { "ShrineRoom", "common1", "common2" } --market, medic
Rooms[Endure] = { "workshop1", "workshop2" } -- training room
Rooms[Luck] = { "StoreRoom", "ShrineRoom", "common1", "common2" } -- market
Rooms[Fade] = { "warehouse1", "common1", "common2" }

ContentsItems = { "diamond", "topaz", "obsidian", "malachite", "lapis_lazuli", "onyx", --"smoky_quartz",
	"sapphire", "garnet", "ash", "rosebud", "blackthorn", "willow", "sage", "foxglove", "mandrake" }

Monsters = {}
Monsters["Endure"] = { "Illusion", "Ogre" }
Monsters["Luck"] = { "Hobgob", "Mimic" }
Monsters["Flow"] = { "Mimic", "Ooze" }
Monsters["Heal"] = { "Ooze", "Phantasm" }
Monsters["Darken"] = { "Phantasm", "Djinn" }
Monsters["Light"] = { "Djinn", "Flamos" }
Monsters["Open"] = { "Flamos", "Ogre" }
Monsters["Hate"] = { "Flamos", "Djinn", "Ogre", "Kobold", "Hobgob", "Mimic", "Goblin" }

Messages = { 
	"Endure --spawns--> Illusion",
	" Luck  --spawns-->   Mimic ",
	"Darken --spawns-->   Djinn ",
	" Flow  --spawns-->   Ooze  ",
	" Heal  --spawns--> Phantasm",
	" Open  --spawns-->   Ogre  ",
	" Light --spawns-->  Flamos ",
	
	"Endure <--consume--   Sage  ",
	" Luck  <--consume--  Willow ",
	"Darken <--consume-- Blackthorn",
	" Flow  <--consume--   ... ",
	" Heal  <--consume--  Foxglove",
	" Open  <--consume--    Ash   ",
	" Light <--consume--  Rosebud ",

	" Break <--cast--  Diamond",
	"Endure <--cast--  Skystone",
	" Luck  <--cast--  Malachite",
	"Darken <--cast--  Obsidian",
	" Flow  <--cast--   Garnet",
	" Heal  <--cast--    Onyx",
	" Open  <--cast--   Topaz",
	" Light <--cast--  Sapphire",

	"_n___e --spawns--> Illusion",
	" _u__  --spawns-->   Mimic ",
	"_ar___ --spawns-->   Djinn ",
	" _l__  --spawns-->   Ooze  ",
	" _e__  --spawns--> Phantasm",
	" __e_  --spawns-->   Ogre  ",
	" _i___ --spawns-->  Flamos ",
	
	"___u__ <--consume--   Sage  ",
	" __c_  <--consume--  Willow ",
	"____e_ <--consume-- Blackthorn",
	" __o_  <--consume--   ... ",
	" __a_  <--consume--  Foxglove",
	" ___n  <--consume--    Ash   ",
	" __gh_ <--consume--  Rosebud ",

	" ____k <--cast--  Diamond",
	"E_____ <--cast--  Skystone",
	" __ck  <--cast--  Malachite",
	"_a__e_ <--cast--  Obsidian",
	" F___  <--cast--   Garnet",
	" _e_l  <--cast--    Onyx",
	" __en  <--cast--   Topaz",
	" _i__t <--cast--  Sapphire",

	"______ --spawns--> Illusion",
	" ____  --spawns-->   Mimic ",
	"______ --spawns-->   Djinn ",
	" ____  --spawns-->   Ooze  ",
	" ____  --spawns--> Phantasm",
	" ____  --spawns-->   Ogre  ",
	" _____ --spawns-->  Flamos ",
	
	"______ <--consume--   Sage  ",
	" ____  <--consume--  Willow ",
	"______ <--consume-- Blackthorn",
	" ____  <--consume--   ... ",
	" ____  <--consume--  Foxglove",
	" ____  <--consume--    Ash   ",
	" _____ <--consume--  Rosebud ",

	" _____ <--cast--  Diamond",
	"______ <--cast--  Skystone",
	" ____  <--cast--  Malachite",
	"______ <--cast--  Obsidian",
	" ____  <--cast--   Garnet",
	" ____  <--cast--    Onyx",
	" ____  <--cast--   Topaz",
	" _____ <--cast--  Sapphire",

	"Endure --spawns--> __l____",
	" Luck  --spawns-->   ____c ",
	"Darken --spawns-->   ____n ",
	" Flow  --spawns-->   _o__  ",
	" Heal  --spawns--> _______m",
	" Open  --spawns-->   _g__  ",
	" Light --spawns-->  _l___ ",
	
	"Endure <--consume--   _a__  ",
	" Luck  <--consume--  _i____ ",
	"Darken <--consume-- _l_______n",
	" Flow  <--consume--   ... ",
	" Heal  <--consume--  _o______",
	" Open  <--consume--    __h   ",
	" Light <--consume--  _o_____",

	" Break <--cast--  _____n_",
	"Endure <--cast--  ______n_",
	" Luck  <--cast--  __l______",
	"Darken <--cast--  _b______",
	" Flow  <--cast--   _a____",
	" Heal  <--cast--    ___x",
	" Open  <--cast--   _o___",
	" Light <--cast--  _a_h____",

	"Endure --spawns--> _______",
	" Luck  --spawns-->   _____ ",
	"Darken --spawns-->   _____ ",
	" Flow  --spawns-->   ____  ",
	" Heal  --spawns--> ________",
	" Open  --spawns-->   ____  ",
	" Light --spawns-->  _____ ",
	
	"Endure <--consume--   ____  ",
	" Luck  <--consume--  ______ ",
	"Darken <--consume-- __________",
	" Flow  <--consume--   ... ",
	" Heal  <--consume--  ________",
	" Open  <--consume--    ___   ",
	" Light <--consume--  _______",

	" Break <--cast--  _______",
	"Endure <--cast--  ________",
	" Luck  <--cast--  _________",
	"Darken <--cast--  ________",
	" Flow  <--cast--   ______",
	" Heal  <--cast--    ____",
	" Open  <--cast--   _____",
	" Light <--cast--  ________",
}

local function ShuffleInPlace(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

ShuffleInPlace(Messages)

Messages.index = 1

function GetNextMessage()
	local message = Messages[Messages.index]
	Messages.index = Messages.index + 1

	if Messages.index > #Messages then
		Messages.index = 1
	end

	return message
end