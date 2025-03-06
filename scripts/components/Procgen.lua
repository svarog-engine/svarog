
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

Items = {}

function MakeObject(what, glyph, other)
	if glyph == nil then glyph = what end
	if other == nil then other = {} end

	local w = what
	local g = glyph

	return function(x, y)
		return World:Entity(
			Position{ x = x, y = y },
			Glyph{ name = g },
			table.unpack(other)
		)
	end
end

local function MakeTemplate(w, h, template, ...)
	local argz = { ... }
	return function(x, y)
		for i = 1, w do
			for j = 1, h do
				local index = j * w + i
				local t = string.sub(template, index, index)
				if tonumber(t) ~= nil then
					if not Dungeon.floor:Has(x + i, y + j) then return end
					if Dungeon.zones:Get(x + i, y + j) == -1 or Dungeon.wallDistances:Get(x + i, y + j) < 2 then return end
				end
			end
		end

		for i = 1, w do
			for j = 1, h do
				if Dungeon.floor:Has(x + i, y + j) and Dungeon.floor:Get(x + i, y + j).type == Floor then
					local index = j * w + i
					local t = string.sub(template, index, index)
					if t ~= "." and t ~= " " and t ~= "\n" and t ~= "\t" then
						local num = tonumber(t)
						if num ~= nil then
							local spots = argz[num]
							local spot = spots[Rand:Range(1, #spots)]
							if spot ~= nil then 
								local e = spot(x + i, y + j)

								if type(e) ~= 'function' then
									Dungeon.zones:Set(x + i, y + j, -1)
									if e[BlockingSight] ~= nil then
										Dungeon.visibility:Set(x + i, y + j, false)
									end

									if e[BlockingPassage] ~= nil then
										Dungeon.passable:Set(x + i, y + j, false)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

local crate = MakeObject("crate", nil,{ Breakable, CanHaveContent, BlockingSight, BlockingPassage })
local chest = MakeObject("chest", nil, { Breakable, CanHaveContent, Locked, BlockingPassage })
local desk = MakeObject("table", nil, { Item, Breakable, BlockingPassage })

function Choose(tbl)
	return function() return tbl[Rand:Range(1, #tbl)] end
end

local key = MakeObject("key", nil, { Item, Key })
local dagger = MakeObject("dagger", nil, { Item, Weapon, Small })
local amulet = MakeObject("amulet", nil, { Item, Amulet, Small })
local goblin = MakeObject("goblin", goblin, { Creature(), AIMoveTowardsPlayer{ distance = 0, chance = 90 }, Health(Range(3)), BumpAttack { damage = 1 }, Glyph{ name = "goblin" }})

local artifact = Choose({ key, dagger })

local common1 = MakeTemplate(3, 3,
[[
.23
.1.
...
]], { nil, nil, nil, nil, nil, nil, key, goblin }, { nil, crate, desk, crate }, { nil, nil, desk, crate })

local common2 = MakeTemplate(4, 3,
[[
.1..
....
1.1.
]], { nil, nil, crate, chest, chest }
)

local alarmTrap = MakeObject("alarm trap", "alarmTrap", { Hidden, Alarm })
local book = MakeObject("book", nil, { Item, Paper, Burnable, Dissolvable })
local warehouse1 = MakeTemplate(5, 5,
[[
..1.
.121.
.121.
.1.1.
.....
]], { nil, crate, crate, crate, crate, crate, crate, crate, crate  }, { nil, nil, nil, book, key, alarmTrap, goblin }
)

local warehouse2 = MakeTemplate(4, 4,
[[
1111
12.1
1.21
1111
]], { crate, desk, shelf }, { nil, nil, chest, chest, crate, goblin })

local shelf = MakeObject("shelf", nil, { Breakable, CanHaveContent, BlockingSight, BlockingPassage })
local library1 = MakeTemplate(3, 3,
[[
1.1
.1.
1.1
]], { nil, shelf, shelf, shelf })

local library2 = MakeTemplate(3, 3,
[[
1.1
...
1.1
]], { nil, shelf, shelf, shelf })

local library3 = MakeTemplate(5, 5,
[[
1.1.1.
.1.2..
1.1.1.
......
]], { shelf, shelf, shelf }, { nil, shelf, chair })

local exhibit1 = MakeTemplate(5, 5,
[[
.....
.222.
.212.
.222.
.....
]], { artifact }, { glass })

local exhibit2 = MakeTemplate(3, 3,
[[
..2
.1.
...
]], { nil, painting, artifact }, { nil, nil, nil, nil, nil, key, amulet })

local anvil = MakeObject("anvil", nil, { BlockingPassage })
local cauldron = MakeObject("cauldron", nil, { BlockingPassage })

local workshop1 = MakeTemplate(5, 5,
[[
.....
.111.
..23.
.4...
.....
]], { nil, shelf, shelf, shelf, crate }, { anvil }, { nil, chair }, { artifact })

local workshop2 = MakeTemplate(3, 3,
[[
111
.21
...
]], { nil, shelf, shelf, shelf, crate }, { anvil, cauldron })

local shrine1 = MakeTemplate(3, 3,
[[
1..
...
..1
]], { candle })

local shrine1 = MakeTemplate(5, 3,
[[
1..1.
.1..1
..11.
]], { nil, candle })

local statue = MakeObject("statue", nil, { BlockingPassage, BlockingSight })
local shrine2 = MakeTemplate(6, 6,
[[
13.1.
3...3
.124.
3...1
.3.1.
]], { nil, nil, candle, candle }, { statue }, { nil, nil, nil, nil, nil, bool, candle }, { nil, nil, nil, artifact })

local furnace = MakeObject("furnace", nil, { BlockingPassage, BlockingSight, Burning })
local grate1 = MakeObject("grate", "grate1", { Metallic })
local grate2 = MakeObject("grate", "grate2", { Metallic })
local grate3 = MakeObject("grate", "grate3", { Metallic })

local forge1 = MakeTemplate(6, 6,
[[
333333
331133
323323
331133
323323
333333
]], { furnace }, { nil, furnace }, { grate1, grate2, grate3, nil })

local forge2 = MakeTemplate(3, 3,
[[
333
213
332
]], { furnace }, { nil, furnace }, { grate, nil })

Rooms = {}
Rooms[Open] = { common1, common2, warehouse1, warehouse2 }
Rooms[Uncover] = { library1, library2, library3, exhibit1, exhibit2 }
Rooms[Enlarge] = { workshop1, workshop2, shrine1, shrine2 }
Rooms[Flow] = { common1, common2 }
Rooms[Calm] = { common1, common2, shrine1 }
Rooms[Rage] = { forge1, forge2, warehouse1, warehouse2, common1 }
Rooms[Yearn] = { exhibit1, exhibit2, shrine2 }
Rooms[Discover] = { library2, workshop2, common1, common2 }
Rooms[Heal] = { common1, common2 } -- market, medic
Rooms[Endure] = { workshop1, workshop2 } -- training room
Rooms[Luck] = { common1, common2, } -- market
Rooms[Fade] = { warehouse1, common1, common2 }

print("PROCGEN DONE") 