local fontMeta = {
	name = "reffspixelfont.png",
	size = 16,
	paddingX  = 1,
	paddingY = 1,
	offsetX = 0,
	offsetY = 0,
}

Glossary.Meta.Default = SpritePresentationMode(fontMeta.name, fontMeta.size, fontMeta.paddingX, fontMeta.paddingY, fontMeta.offsetX, fontMeta.offsetY)

Glossary.Default = {
	goblin = { x = 7, y = 2, fg = Colors.LightGreen, bg = Colors.Black },
	kobold = { x = 11, y = 2, fg = Colors.LightRed, bg = Colors.Black },

	player = { x = 0, y = 1, fg = Colors.Yellow, bg = Colors.Black },
	pet = { x = 4, y = 2, fg = Colors.Yellow, bg = Colors.Black },

	mage = { x = 0, y = 1, fg = Colors.LightBlue, bg = Colors.Black },
	monk = { x = 12, y = 1, fg = Colors.Yellow, bg = Colors.Black },

	door_open = { x = 11, y = 0, fg = Colors.Gray, bg = Colors.Black },
	door_closed = { x = 13, y = 0, fg = Colors.Gray, bg = Colors.Black },

	back_dark = { x = 23, y = 4, fg = Colors.DarkBrown, bg = Colors.Black },
	back_semi = { x = 23, y = 4, fg = Colors.Brown, bg = Colors.Black },
	back_mid = { x = 23, y = 4, fg = Colors.Brown, bg = Colors.Black },
	back_lit = { x = 23, y = 4, fg = Colors.Brown, bg = Colors.Black },

	empty_tile = { x = 0, y = 0, fg = Colors.DarkGray, bg = Colors.Black },
	
	wall = { x = 3, y = 0, fg = Colors.DarkGray, bg = Colors.Black },
	treasure = { x = 4, y =0, fg = Colors.LightYellow, bg = Colors.Black },
	item = { x = 15, y = 0, fg = Colors.Yellow, bg = Colors.Black },
	key = { x = 27, y = 0, fg = Colors.Yellow, bg = Colors.Black },

	empty = { x = 0, y = 0, fg = Colors.DarkGray, bg = Colors.Black },
	invalid = { x = -1, y = -1, fg = Colors.Transparent, bg = Colors.Transparent },

	crate = { x = 29, y = 0, fg = Colors.Gray, bg = Colors.Black },
	table = { x = 14, y = 1, fg = Colors.Gray, bg = Colors.Black },
	barrel = { x = 15, y = 2, fg = Colors.Gray, bg = Colors.Black },
	steelKey = { x = 6, y = 2, fg = Colors.LightBlue, bg = Colors.Black },
	ironKey = { x = 6, y = 2, fg = Colors.Gray, bg = Colors.Black },
	silverKey = { x = 6, y = 2, fg = Colors.LightGray, bg = Colors.Black },
	darkoreKey = { x = 6, y = 2, fg = Colors.DarkRed, bg = Colors.Black },
	alarmTrap = { x = 13, y = 20, fg = Colors.LightRed, bg = Colors.DarkRed },
	book = { x = 3, y = 2, fg = Colors.Brown, bg = Colors.Black },
}

InsertSpriteCharRanges(Glossary.Default, 1, 1, "ABCDEFGHIJKLMNOPQRSTUVWXYZ[ ]^_")
InsertSpriteCharRanges(Glossary.Default, 1, 2, "abcdefghijklmnopqrstuvwxyz{|}~")
InsertSpriteCharRanges(Glossary.Default, 0, 0, " ")

InsertSpriteCharRanges(Glossary.Default, 11, 0, "+,-./0123456789:;<=>?")
InsertSpriteCharRanges(Glossary.Default, 1, 0, "!@#$%&")
