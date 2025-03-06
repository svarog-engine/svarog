
Name = ECS.Component("")
Burnable = ECS.Component()
Dissolvable = ECS.Component()

Weapon = ECS.Component()
Amulet = ECS.Component()
Small = ECS.Component()

Key = ECS.Component()
Locked = ECS.Component()

BlockingPassage = ECS.Component()
BlockingSight = ECS.Component()

Breakable = ECS.Component()
CanHaveContent = ECS.Component()

Objects = {}
Templates = {}

IDS = 1

function RegisterObject(what, glyph, ...)
	Objects[what] = {
		Glyph{ name = glyph },
		...
	}
end

function MakeObject(what, x, y)
	if Objects[what] ~= nil then
		
		local e = World:Entity(Position{ x = x, y = y })
		for _, v in ipairs(Objects[what]()) do 
			e:Set(v)
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
								MakeObject(spot, xx, yy)
							end
						end
					end
				end
			end
		end
	end
end

RegisterObject("crate", nil, function(e) e:Set(Breakable, CanHaveContent, BlockingSight, BlockingPassage, Name("crate")) end)
RegisterObject("chest", nil, function(e) e:Set(Breakable, CanHaveContent, Locked, BlockingPassage, Name("chest")) end)
RegisterObject("table", nil, function(e) e:Set(Item, Breakable, BlockingPassage, Name("table")) end)

function Choose(tbl)
	return function() return tbl[Rand:Range(1, #tbl)] end
end

RegisterObject("key", nil, function(e) e:Set(Item, Key, Name("key")) end)
RegisterObject("dagger", nil, function(e) e:Set(Item, Weapon, Small, Name("dagger")) end)
RegisterObject("amulet", nil, function(e) e:Set(Item, Amulet, Small, Name("amulet")) end)

RegisterObject("goblin", nil, function(e) e:Set(Creature(), AIMoveTowardsPlayer{ distance = 0, chance = 9 }, Health(Range(3)), BumpAttack { damage = 1 }, Glyph{ name = "goblin" }, Name("goblin")) end)

local artifact = Choose({ key, dagger })

MakeTemplate("common1", 3, 3,
[[
.23
.1.
...
]], { nil, nil, nil, nil, nil, nil, "key", "goblin" }, { nil, "crate", "desk", "crate" }, { nil, nil, "desk", "crate" })

MakeTemplate("common2", 4, 3,
[[
.1..
....
1.1.
]], { nil, nil, "crate", "chest", "chest" }
)

RegisterObject("alarm trap", "alarmTrap", function(e) e:Set(Hidden, Alarm) end)
RegisterObject("book", nil, function(e) e:Set(Item, Paper, Burnable, Dissolvable) end)
MakeTemplate("warehouse1", 5, 5,
[[
..1.
.121.
.121.
.1.1.
.....
]], { nil, "crate", "crate", "crate", "crate" }, { nil, nil, nil, "book", "key", "alarmTrap", "goblin" }
)

MakeTemplate("warehouse2", 4, 4,
[[
1111
12.1
1.21
1111
]], { "crate", "desk", "shelf" }, { nil, nil, "chest", "chest", "crate", "goblin" })

RegisterObject("shelf", nil, function(e) e:Set(Breakable, CanHaveContent, BlockingSight, BlockingPassage, Name("shelf")) end)
MakeTemplate("library1", 3, 3,
[[
1.1
.1.
1.1
]], { nil, "shelf", "shelf", "shelf" })

MakeTemplate("library2", 3, 3,
[[
1.1
...
1.1
]], { nil, "shelf", "shelf", "shelf" })

MakeTemplate("library3", 5, 5,
[[
1.1.1.
.1.2..
1.1.1.
......
]], { "shelf", "shelf", "shelf" }, { nil, "shelf", "chair" })

MakeTemplate("exhibit1", 5, 5,
[[
.....
.222.
.212.
.222.
.....
]], { "artifact" }, { "glass" })

MakeTemplate("exhibit2", 3, 3,
[[
..2
.1.
...
]], { nil, "painting", "artifact" }, { nil, nil, nil, nil, nil, "key", "amulet" })

RegisterObject("anvil", nil, function(e) e:Set(BlockingPassage, Name("anvil")) end)
RegisterObject("cauldron", nil, function(e) e:Set(BlockingPassage, Name("cauldron")) end)

MakeTemplate("workshop1", 5, 5,
[[
.....
.111.
..23.
.4...
.....
]], { nil, "shelf", "shelf", "shelf", "crate" }, { "anvil" }, { nil, "desk" }, { "artifact" })

MakeTemplate("workshop2", 3, 3,
[[
111
.21
...
]], { nil, "shelf", "shelf", "shelf", "crate" }, { "anvil", "cauldron" })

MakeTemplate("shrine1", 3, 3,
[[
1..
...
..1
]], { "candle" })

MakeTemplate("shrine1", 5, 3,
[[
1..1.
.1..1
..11.
]], { nil, "candle" })

RegisterObject("statue", nil, function(e) e:Set(BlockingPassage, BlockingSight, Name("statue")) end)
MakeTemplate("shrine2", 6, 6,
[[
13.1.
3...3
.124.
3...1
.3.1.
]], { nil, nil, "candle", "candle" }, { "statue" }, { nil, nil, nil, nil, nil, "book", "candle" }, { nil, nil, nil, "artifact" })

RegisterObject("furnace", nil, function(e) e:Set(BlockingPassage, BlockingSight, Burning, Name("furnace")) end)
RegisterObject("grate", "grate1", function(e) e:Set(Metallic, Name("grate")) end)
RegisterObject("grate", "grate2", function(e) e:Set(Metallic, Name("grate")) end)
RegisterObject("grate", "grate3", function(e) e:Set(Metallic, Name("grate")) end)

MakeTemplate("forge1", 6, 6,
[[
333333
3.1.3.
323323
3.1.3.
323323
3.3.3.
]], { "furnace" }, { nil, "furnace" }, { "grate1", "grate2", "grate3" })

MakeTemplate("forge2", 3, 3,
[[
333
213
332
]], { "furnace" }, { nil, "furnace" }, { "grate", nil })

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
