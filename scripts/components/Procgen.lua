
Name = ECS.Component("")
Burnable = ECS.Component()
Burning = ECS.Component{value = 0.0}
Unburnable = ECS.Component()

Dissolvable = ECS.Component()

Weapon = ECS.Component()
Amulet = ECS.Component()
Small = ECS.Component()
Paper = ECS.Component()

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
	local e = World:Entity(Position{ x = x, y = y })
		
	e:Set(Name(what))
	e:Set(ID(IDS))
	IDS = IDS + 1

	if Procgen[what] == nil then
		Svarog.Instance:LogError("PROCGEN: Generator " .. what .. " not found. Check your spelling.")
	end
	Procgen[what](e, x, y, ...)
	AddEntityToDungeon(x, y, e)
	return e
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

function Procgen.Crate(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsWooden(e)
	Procgen.IsContainer(e)
	Procgen.GenerateContents(e, Minerals)
	e:Set(Glyph{ name = "crate" })
end

function Procgen.Flame(e, x, y, lifetime, spread)
	e:Set(Burning{ value = Rand:F01() })
	e:Set(Health{ value = lifetime or 20 })
	e:Set(Spread{ chance = spread or 4 })
	e:Set(Glyph{ name = "flame" })
end

function Procgen.Cinders(e, x, y)
	e:Set(Glyph{ name = "cinders" })
	e:Set(Unburnable{})
end

function Procgen.Chest(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsContainer(e)
	Procgen.GenerateContents(e, Minerals)
	e:Set(Locked{})
	e:Set(Glyph{ name = "chest" })
end

function Procgen.Table(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsWooden(e)
	e:Set(Glyph{ name = "table" })
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
		AIMoveTowardsPlayer{ distance = 0, chance = 6 }, 
		Health{ value = Range(2) }, 
		BumpAttack { damage = 1 }, 
		Glyph{ name = "goblin" },
		Burnable{},
		Contents{ items = { { itemId = "gold", quantity = 20 } } }
	)
end

function Procgen.AlarmTrap(e, x, y)
	e:Set(Invisible(Range(100)), Alarm{})
	e:Set(Glyph{ name = "alarmTrap" })
end

function Procgen.Book(e, x, y)
	Procgen.IsPaper(e)
	e:Set(Item{})
	e:Set(Glyph{ name = "book" })
end

function Procgen.Shelf(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsWooden(e)
	Procgen.IsContainer(e)
	Procgen.GenerateContents(e, Books)
	e:Set(Glyph{ name = "shelf" })
end

function Procgen.Anvil(e, x, y)
	e:Set(BlockingPassage{})
	e:Set(Glyph{ name = "anvil" })
end

function Procgen.Cauldron(e, x, y)
	e:Set(BlockingPassage{})
	e:Set(Glyph{ name = "cauldron" })
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

function Procgen.Portal(e, x, y, owner, time)
	e:Set(Name("Portal"))
	e:Set(Dependent(owner))
	e:Set(Portal{ challenge = owner })
	e:Set(Magic{ value = Rand:F01(), colors = { Colors.DarkMagenta, Colors.Black } })
	e:Set(Timeout{ value = time or 9 })
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

--Monsters[Endure] = { "Hobgob", "Mimic" }
--Monsters[Break] = { "Acid Cube", "Ogre" }
--Monsters[Luck] = { "Plague Rats", "Vampire" }
--Monsters[Darken] = { "Shade", "Wraith" }
--Monsters[Flow] = { "Restless Dead", "Gelatinous Cube" }
--Monsters[Heal] = { "Kobold", "Phantasm" }
--Monsters[Calm] = { "Banshee", "Nightmare" }
--Monsters[Steal] = { "Hobgob", "Mimic" }
--Monsters[Light] = { "Wisp", "Djinn" }

function Procgen.Hobgob(e, x, y)
	e:Set(
		Creature{}, 
		AIMoveTowardsPlayer{ distance = 0, chance = 3 }, 
		Health{ value = Range(5) }, 
		BumpAttack { damage = 1 }, 
		Glyph{ name = "hobgob" },
		Contents{ items = {} }
	)
end

function Procgen.Mimic(e, x, y)
	e:Set(
		Creature{}, 
		AIAttackIfStandingNextTo{}, 
		AIMoveTowardsPlayer{ distance = 10, chance = 1 }, 
		Health{ value = Range(7) }, 
		BumpAttack { damage = 3 }, 
		Glyph{ name = "chest" },
		Burnable{},
		Contents{ items = {} }
	)
end

function Procgen.Ogre(e, x, y)
	e:Set(
		Creature{}, 
		AIMoveTowardsPlayer{ distance = 0, chance = 8 },
		AIRest{ chance = 9 },
		AIBreakThroughToPlayer{ chance = 5, distance = 9 },
		Health{ value = Range(3) }, 
		BumpAttack { damage = 3 }, 
		Glyph{ name = "ogre" },
		Contents{ items = {} }
	)
end

function Procgen.GenerateContents(e, x, y)
	local items = { Minerals[Rand:Range(1, #Minerals)] }
	e:Set(Contents { items = items })
end

function Templates.LibraryRoom(cx, cy)
	if Dungeon.wallDistances:Get(cx, cy) >= 2 then
		local room = DistanceMap:From(Dungeon.floor, { { cx, cy } }, 0, 7)
		room:AddCondition(function(map, x, y) return Dungeon.wallDistances:Has(x, y) and Dungeon.wallDistances:Get(x, y) >= 2 end)
		room:Flood()

		local w, h = Dungeon.floor:Size()
		for i = 1, w, 2 do
			for j = 1, h, 2 do
				Dungeon.zones:Set(i, j, -1)
				if room:Has(i, j) and room:Get(i, j) >= 0 and room:Get(i, j) < 10 then
					Procgen.MakeObject("Shelf", i, j)
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
.1.1.
.1.1.
]], { nil, "Crate", "Crate", "Crate", "Crate" }, { nil, nil, nil, "Book", "Key", "AlarmTrap", "Goblin" }
)

MakeTemplate("warehouse2", 4, 4,
[[
1111
1...
1..1
1111
]], { "Crate", "Table", "Shelf" }, { nil, nil, "Chest", "Chest", "Crate" })

MakeTemplate("warehouse3", 4, 4,
[[
1111
....
1..1
1.11
]], { "Crate", "Table", "Shelf" }, { nil, nil, "Chest", "Chest", "Crate" })

MakeTemplate("library1", 3, 3,
[[
...
.1.
...
]], { "Shelf" })

MakeTemplate("library2", 3, 3,
[[
1..
...
..1
]], { "Shelf" })

MakeTemplate("library3", 5, 3,
[[
1...1
.....
1...1
]], { "Shelf" })

MakeTemplate("exhibit1", 5, 5,
[[
.....
.....
..1..
.....
.....
]], { "Artifact" })

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
]], { nil, "Shelf", "Shelf", "Shelf", "Crate" }, { "Anvil" }, { nil, "Table" }, { "Artifact" })

MakeTemplate("workshop2", 3, 3,
[[
111
.21
...
]], { nil, "Shelf", "Shelf", "Shelf", "Crate" }, { "Anvil", "Cauldron" })

MakeTemplate("shrine1", 3, 3,
[[
1..
...
..1
]], { "Candle" })

MakeTemplate("shrine1", 5, 3,
[[
1...1
1...1
1...1
]], { nil, "Candle" })

MakeTemplate("shrine2", 6, 6,
[[
13.1.
3...3
.124.
3...1
.3.1.
]], { "Candle" }, { "Statue" }, { nil, nil, nil, nil, nil, "Book", "Candle" }, { nil, nil, nil, "Artifact" })

MakeTemplate("forge1", 5, 5,
[[
33333
3.1.3
32332
3.1.3
32332
]], { "Furnace" }, { nil, "Furnace" }, { "Grate" })

MakeTemplate("forge2", 3, 3,
[[
333
213
332
]], { "Furnace" }, { nil, "Furnace" }, { "Grate", nil })

Rooms = {}
Rooms[Open] = { "common1", "common2", "warehouse1", "warehouse2" }
Rooms[Uncover] = { "LibraryRoom", "exhibit1", "exhibit2" }
Rooms[Enlarge] = { "workshop1", "workshop2", "shrine1", "shrine2" }
Rooms[Flow] = { "common1", "common2" }
Rooms[Calm] = { "common1", "common2", "shrine1" }
Rooms[Rage] = { "forge1", "forge2", "warehouse1", "warehouse2", "common1" }
Rooms[Yearn] = { "exhibit1", "exhibit2", "shrine2" }
Rooms[Discover] = { "library2", "workshop2", "common1", "common2" }
Rooms[Heal] = { "common1", "common2" } --market, medic
Rooms[Endure] = { "workshop1", "workshop2" } -- training room
Rooms[Luck] = { "common1", "common2" } -- market
Rooms[Fade] = { "warehouse1", "common1", "common2" }

Minerals = {"diamond", "topaz", "obsidian", "malachite", "lapis_lazuli", "onyx", "smoky_quartz" }
Plants = {"ash", "frankincense", "blackthorn", "willow", "sage", "foxglove", "mandrake" }
Books = { "book" }

Monsters = {}
Monsters[Endure] = { "Hobgob", "Mimic" }
Monsters[Break] = { "Acid Cube", "Ogre" }
Monsters[Luck] = { "Plague Rats", "Vampire" }
Monsters[Darken] = { "Shade", "Wraith" }
Monsters[Flow] = { "Restless Dead", "Gelatinous Cube" }
Monsters[Heal] = { "Kobold", "Phantasm" }
Monsters[Calm] = { "Banshee", "Nightmare" }
Monsters[Steal] = { "Hobgob", "Mimic" }
Monsters[Light] = { "Wisp", "Djinn" }
