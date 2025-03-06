
Name = ECS.Component("")
Burnable = ECS.Component()
Burning = ECS.Component()
Dissolvable = ECS.Component()

Weapon = ECS.Component()
Amulet = ECS.Component()
Small = ECS.Component()
Paper = ECS.Component()

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

function Procgen.Crate(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsWooden(e)
	e:Set(Glyph{ name = "crate" })
end

function Procgen.Chest(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsContainer(e)
	e:Set(Locked{})
	e:Set(Glyph{ name = "chest" })
end

function Procgen.Table(e, x, y)
	Procgen.IsFurniture(e)
	Procgen.IsWooden(e)
	e:Set(Glyph{ name = "table" })
end

function Procgen.Key(e, x, y)
	e:Set(Item{}, Key{}, Metallic{})
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
	e:Set(Creature{}, AIMoveTowardsPlayer{ distance = 0, chance = 9 }, Health{ value = Range(3) }, BumpAttack { damage = 1 }, Glyph{ name = "goblin" })
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
	e:Set(Glyph{ name = "shelf" })
end

function Procgen.Anvil(e, x, y)
	e:Set(BlockingPassage{})
	e:Set(Glyph{ name = "anvil" })
end

function Procgen.Cauldron(e, x, y)
	e:Set(BlockingPassage{})
	e:Set(Glyph{ name = "cauldron" })
end

function Procgen.Statue(e, x, y)
	e:Set(BlockingPassage{})
	e:Set(Glyph{ name = "statue" })
end

function Procgen.Candle(e, x, y)
	e:Set(BlockingPassage{})
	if Rand:Range(1, 10) < 5 then
		e:Set(Burning{})
	end
	e:Set(Glyph{ name = "candle" })
end

function Procgen.Furnace(e, x, y)
	e:Set(BlockingPassage{})
	e:Set(Burning{})
	e:Set(Glyph{ name = "furnace" })
end

function Procgen.Grate(e, x, y)
	e:Set(Metallic{})
	e:Set(Glyph{ name = "grate" .. Rand:Range(1, 3) })
end

function MakeObject(what, x, y)
	local e = World:Entity(Position{ x = x, y = y })
		
	e:Set(Name(what))
	e:Set(ID(IDS))
	IDS = IDS + 1

	print(what, Procgen[what])
	Procgen[what](e, x, y)
	AddEntityToDungeon(x, y, e)
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
								MakeObject(spot, xx, yy)
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
]], { nil, nil, nil, nil, nil, nil, "Key", "Goblin" }, { nil, "Crate", "Desk", "Crate" }, { nil, nil, "Desk", "Crate" })

MakeTemplate("common2", 4, 3,
[[
.1..
....
1.1.
]], { nil, nil, "Crate", "Chest", "Chest" }
)

MakeTemplate("warehouse1", 5, 5,
[[
..1.
.121.
.121.
.1.1.
.....
]], { nil, "Crate", "Crate", "Crate", "Crate" }, { nil, nil, nil, "Book", "Key", "AlarmTrap", "Goblin" }
)

MakeTemplate("warehouse2", 4, 4,
[[
1111
12.1
1.21
1111
]], { "Crate", "Desk", "Shelf" }, { nil, nil, "Chest", "Chest", "Crate", "Goblin" })

MakeTemplate("library1", 3, 3,
[[
1.1
.1.
1.1
]], { nil, "Shelf", "Shelf", "Shelf" })

MakeTemplate("library2", 3, 3,
[[
1.1
...
1.1
]], { nil, "Shelf", "Shelf", "Shelf" })

MakeTemplate("library3", 5, 5,
[[
1.1.1.
.1.2..
1.1.1.
......
]], { "Shelf", "Shelf", "Shelf" }, { nil, "Shelf", "Chair" })

MakeTemplate("exhibit1", 5, 5,
[[
.....
.222.
.212.
.222.
.....
]], { "Artifact" }, { "Glass" })

MakeTemplate("exhibit2", 3, 3,
[[
..2
.1.
...
]], { nil, "Painting", "Artifact" }, { nil, nil, nil, nil, nil, "Key", "Amulet" })

MakeTemplate("workshop1", 5, 5,
[[
.....
.111.
..23.
.4...
.....
]], { nil, "Shelf", "Shelf", "Shelf", "Crate" }, { "Anvil" }, { nil, "Desk" }, { "Artifact" })

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
1..1.
.1..1
..11.
]], { nil, "Candle" })

MakeTemplate("shrine2", 6, 6,
[[
13.1.
3...3
.124.
3...1
.3.1.
]], { nil, nil, "Candle", "Candle" }, { "Statue" }, { nil, nil, nil, nil, nil, "Book", "Candle" }, { nil, nil, nil, "Artifact" })

MakeTemplate("forge1", 6, 6,
[[
333333
3.1.3.
323323
3.1.3.
323323
3.3.3.
]], { "Furnace" }, { nil, "Furnace" }, { "Grate" })

MakeTemplate("forge2", 3, 3,
[[
333
213
332
]], { "Furnace" }, { nil, "Furnace" }, { "Grate", nil })

Rooms = {}
Rooms[Open] = { "common1", "common2", "warehouse1", "warehouse2" }
Rooms[Uncover] = { "library1", "library2", "library3", "exhibit1", "exhibit2" }
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
