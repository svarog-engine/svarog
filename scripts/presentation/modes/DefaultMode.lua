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
	target = { x = 10, y = 0, fg = Colors.White, bg = Colors.Black },
	target2 = { x = 31, y = 2, fg = Colors.White, bg = Colors.Black },
	target3 = { x = 10, y = 3, fg = Colors.White, bg = Colors.Black },
	target4 = { x = 11, y = 3, fg = Colors.White, bg = Colors.Black },
	
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
	key = { x = 16, y = 4, fg = Colors.Yellow, bg = Colors.Black },

	empty = { x = 0, y = 0, fg = Colors.DarkGray, bg = Colors.Black },
	invalid = { x = -1, y = -1, fg = Colors.Transparent, bg = Colors.Transparent },

	crate = { x = 13, y = 4, fg = Colors.White, bg = Colors.Black },
	crate_empty = { x = 14, y = 4, fg = Colors.White, bg = Colors.Black },
	chest = { x = 12, y = 4, fg = Colors.LightBlue, bg = Colors.Black },
	chest_empty = { x = 11, y = 4, fg = Colors.LightBlue, bg = Colors.Black },
	table = { x = 0, y = 2, fg = Colors.LightBrown, bg = Colors.Black },
	alarmTrap = { x = 13, y = 20, fg = Colors.LightRed, bg = Colors.DarkRed },
	shelf = { x = 27, y = 2, fg = Colors.Green, bg = Colors.Black },
	shelf_empty = { x = 27, y = 1, fg = Colors.Green, bg = Colors.Black },
	book = { x = 0, y = 3, fg = Colors.LightBrown, bg = Colors.Black },
	anvil = { x = 25, y = 1, fg = Colors.LightGray, bg = Colors.Black },
	cauldron = { x = 21, y = 1, fg = Colors.Black, bg = Colors.LightBlue },
	statue = { x = 0, y = 1, fg = Colors.LightGray, bg = Colors.DarkGray },
	furnace = { x = 20, y = 15, fg = Colors.Black, bg = Colors.LightRed },
	candle = { x = 13, y = 6, fg = Colors.Yellow, bg = Colors.Black },
	grate1 = { x = 31, y = 1, fg = Colors.DarkBlue, bg = Colors.LightRed },
	grate2 = { x = 31, y = 1, fg = Colors.LightBlue, bg = Colors.DarkRed },
	grate3 = { x = 31, y = 1, fg = Colors.White, bg = Colors.Red },
	flame = { x = 30, y = 1, fg = Colors.White, bg = Colors.Black },
	cinders = { x = 12, y = 0, fg = Colors.Red, bg = Colors.Black },
	rift = { x = 9, y = 3, fg = Colors.Red, bg = Colors.Black },
	portal = { x = 10, y = 16, fg = Colors.Magenta, bg = Colors.Black },
	platform = { x = 31, y = 3, fg = Colors.White, bg = Colors.Magenta },

	gold = { x = 4, y = 0, fg = Colors.Yellow, bg = Colors.Black },
	mineral = { x = 5, y = 0, fg = Colors.Green, bg = Colors.Black },
	plant = { x = 6, y = 0, fg = Colors.Blue, bg = Colors.Black },
	
	sphere = { x = 4, y = 4, fg = Colors.White, bg = Colors.Black },
	dust = { x = 30, y = 3, fg = Colors.Gray, bg = Colors.Black },
	altar = { x = 3, y = 3, fg = Colors.Blue, bg = Colors.Black },
	goblin = { x = 7, y = 2, fg = Colors.LightGreen, bg = Colors.Black },
	kobold = { x = 11, y = 2, fg = Colors.LightRed, bg = Colors.Black },
	hobgob = { x = 7, y = 1, fg = Colors.DarkGreen, bg = Colors.Black },
	ogre = { x = 14, y = 9, fg = Colors.LightRed, bg = Colors.Black },
	blob = { x = 3, y = 1,  fg = Colors.LightRed, bg = Colors.Black },
	gelly = { x = 3, y = 1, fg = Colors.Magenta, bg = Colors.Black },
	djinn = { x = 16, y = 5, fg = Colors.LightRed, bg = Colors.Black },
	throne = { x = 7, y = 8, fg = Colors.DarkYellow, bg = Colors.Black },
	skeleton = { x = 5, y = 0, fg = Colors.Gray, bg = Colors.Black },
	restless = { x = 5, y = 0, fg = Colors.Gray, bg = Colors.Black },
	third_eye_closed = { x = 1, y = 3, fg = Colors.Red, bg = Colors.Black },
	third_eye_opened = { x = 2, y = 3, fg = Colors.White, bg = Colors.Black },
	up_arrow = { x = 5, y = 3, fg = Colors.White, bg = Colors.Black },
	down_arrow = { x = 6, y = 3, fg = Colors.White, bg = Colors.Black },
}

InsertSpriteCharRanges(Glossary.Default, 1, 1, "ABCDEFGHIJKLMNOPQRSTUVWXYZ[ ]^_")
InsertSpriteCharRanges(Glossary.Default, 1, 2, "abcdefghijklmnopqrstuvwxyz{|}~")
InsertSpriteCharRanges(Glossary.Default, 0, 0, " ")

InsertSpriteCharRanges(Glossary.Default, 11, 0, "+,-./0123456789:;<=>?")
InsertSpriteCharRanges(Glossary.Default, 1, 0, "!@#$%&")
InsertSpriteCharRanges(Glossary.Default, 8, 0, "()")
InsertSpriteCharRanges(Glossary.Default, 7, 0, "'")
InsertSpriteCharRanges(Glossary.Default, 2, 0, "\"")
