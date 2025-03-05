
Burnable = ECS.Component()
Dissolvable = ECS.Component()

Key = ECS.Component()
Locked = ECS.Component()

BlockingPassage = ECS.Component()
BlockingSight = ECS.Component()

Breakable = ECS.Component()
CanHaveContent = ECS.Component()

Items = {}

function MakeItem(what, glyph, other)
	if glyph == nil then glyph = what end
	if other == nil then other = {} end

	Items[what] = {
		callback = function(x, y)
			World:Entity(
				Item{ id = what },
				Position{ x = x, y = y },
				Glyph{ name = glyph },
				table.unpack(other)
			)
		end
	}
end

function MakeTemplate(w, h, template, ...)
	local template = {}
	template.width = w
	template.height = h 
	template.map = template
	template.args = arg
	return template
end

function MakeCollection(name, collection)
	local coll = {}
	coll.name = name
	coll.items = collection
	return coll
end

local crate = MakeItem("crate", { Breakable, CanHaveContent, BlockingSight, BlockingPassage })
local chest = MakeItem("chest", "crate", { Breakable, CanHaveContent, Locked, BlockingPassage })
local table = MakeItem("table", { Breakable, BlockingPassage })
local barrel = MakeItem("barrel", { Breakable, CanHaveContent, BlockingPassage })

local steelKey = MakeItem("steel key", "steelKey", { Steel, Key })
local ironKey = MakeItem("iron key", "ironKey", { Iron, Key })
local silverKey = MakeItem("silver key", "silverKey", { Silver, Key })
local darkoreKey = MakeItem("darkore key", "darkoreKey", { Darkore, Key })

function Choose(tbl)
	return true
end

local RESOLVE_METAL = Choose({ Steel, Iron, Silver, Darkore })
local key = MakeItem("key", { RESOLVE_METAL })
local key = MakeItem("dagger", { RESOLVE_METAL, Weapon, Small })

local artifact = MakeCollection("artifact", {})

local common1 = MakeTemplate(3, 3,
[[
.23
.1.
...
]], { nil, nil, nil, nil, nil, nil, steelKey, ironKey }, { nil, barrel, table, crate }, { nil, nil, table, crate })

local common2 = MakeTemplate(4, 3,
[[
.1..
....
1.1.
]], { nil, nil, crate, barrel }
)

local alarmTrap = MakeItem("alarm trap", "alarmTrap", { Hidden, Alarm{ distance = 0 } })
local book = MakeItem("book", { Paper, Burnable, Dissolvable })
local warehouse1 = MakeTemplate(5, 5,
[[
..1.
.121.
.121.
.1.1.
.....
]], { nil, crate, crate, barrel, barrel }, { nil, nil, nil, book, key, alarmTrap }
)

local warehouse2 = MakeTemplate(4, 4,
[[
1111
12.1
1.21
1111
]], { crate, barrel }, { nil, nil, nil, chest, crate, barrel })

local shelf = MakeItem("shelf", { Breakable, CanHaveContent, BlockingSight, BlockingPassage })
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
]], { nil, shelf, shelf, shelf }, { nil, shelf, chair })

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
]], { nil, painting, artifact }, { nil, nil, nil, nil, nil, darkoreKey, silverKey })

local anvil = MakeItem("anvil", { BlockingPassage })
local workshop1 = MakeTemplate(5, 5,
[[
.....
.111.
..23.
.4...
.....
]], { nil, shelf, shelf, shelf, crate, barrel }, { anvil }, { nil, chair }, { artifact })

local workshop2 = MakeTemplate(3, 3,
[[
111
.21
...
]], { nil, shelf, shelf, shelf, crate }, { anvil, cauldron })

