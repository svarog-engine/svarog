
Glossary.Meta.Goblins = SpritePresentationMode("goblins-12x12.png", 12, 40)

Glossary.Goblins = {
	goblin = { x = 15, y = 8, fg = Colors.LightGreen, bg = Colors.Black },
	kobold = { x = 25, y = 9, fg = Colors.LightRed, bg = Colors.Black },

	player = { x = 32, y = 5, fg = Colors.Yellow, bg = Colors.Black },
	pet = { x = 26, y = 11, fg = Colors.Yellow, bg = Colors.Black },

	mage = { x = 20, y = 9, fg = Colors.LightBlue, bg = Colors.Black },
	monk = { x = 21, y = 9, fg = Colors.Yellow, bg = Colors.Black },

	door_open = { x = 15, y = 16, fg = Colors.Gray, bg = Colors.Black },
	door_closed = { x = 16, y = 16, fg = Colors.Gray, bg = Colors.Black },

	back_dark = { x = 5, y = 16, fg = Colors.DarkBrown, bg = Colors.Black },
	back_semi = { x = 5, y = 16, fg = Colors.Brown, bg = Colors.Black },
	back_mid = { x = 5, y = 15, fg = Colors.Brown, bg = Colors.Black },
	back_lit = { x = 5, y = 14, fg = Colors.Brown, bg = Colors.Black },

	empty = { x = 5, y = 13, fg = Colors.DarkGray, bg = Colors.Black },
	
	wall = { x = 16, y = 17, fg = Colors.DarkGray, bg = Colors.Black },
}

InsertSpriteCharRanges(Glossary.Goblins, 0, 0, " ")
InsertSpriteCharRanges(Glossary.Goblins, 29, 2, "ABCDEFGHIJK")
InsertSpriteCharRanges(Glossary.Goblins, 29, 2, "abcdefghijk")
InsertSpriteCharRanges(Glossary.Goblins, 29, 3, "LMNOPQRSTUV")
InsertSpriteCharRanges(Glossary.Goblins, 29, 3, "lmnopqrstuv")
InsertSpriteCharRanges(Glossary.Goblins, 29, 4, "WXYZ0123456")
InsertSpriteCharRanges(Glossary.Goblins, 29, 4, "wxyz0123456")
InsertSpriteCharRanges(Glossary.Goblins, 27, 5, "-.789@!?")