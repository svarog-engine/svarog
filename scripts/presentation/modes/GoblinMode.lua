
Glossary.Meta.Goblins = SpritePresentationMode("goblins-12x12.png", 12, 40)

Glossary.Goblins = {
	skel1 = { x = 13, y = 8, fg = Colors.Gray, bg = Colors.Black },
	skel2 = { x = 14, y = 8, fg = Colors.Gray, bg = Colors.Black },

	gob1 = { x = 15, y = 8, fg = Colors.White, bg = Colors.Black },
	gob2 = { x = 16, y = 8, fg = Colors.Green, bg = Colors.Black },

	kobold1 = { x = 25, y = 9, fg = Colors.White, bg = Colors.Black },
	kobold2 = { x = 26, y = 9, fg = Colors.Red, bg = Colors.Black },

	player = { x = 32, y = 5, fg = Colors.Yellow, bg = Colors.Black },
	mage = { x = 20, y = 9, fg = Colors.LightBlue, bg = Colors.Black },
	monk = { x = 21, y = 9, fg = Colors.Yellow, bg = Colors.Black },

	door_open = { x = 15, y = 16, fg = Colors.Gray, bg = Colors.Black },
	door_closed = { x = 16, y = 16, fg = Colors.Gray, bg = Colors.Black },

	back_dark = { x = 0, y = 0, fg = Colors.DarkBrown, bg = Colors.Black },
	back_semi = { x = 6, y = 17, fg = Colors.DarkBrown, bg = Colors.Black },
	back_mid = { x = 6, y = 16, fg = Colors.DarkBrown, bg = Colors.Black },
	back_lit = { x = 5, y = 15, fg = Colors.DarkBrown, bg = Colors.Black },

	back_old1 = { x = 6, y = 14, fg = Colors.DarkGray, bg = Colors.Black },
	back_old2 = { x = 7, y = 14, fg = Colors.DarkGray, bg = Colors.Black },
	back_old3 = { x = 8, y = 14, fg = Colors.DarkGray, bg = Colors.Black },
}

InsertSpriteCharRanges(Glossary.Goblins, 0, 0, " ")
InsertSpriteCharRanges(Glossary.Goblins, 29, 2, "ABCDEFGHIJK")
InsertSpriteCharRanges(Glossary.Goblins, 29, 2, "abcdefghijk")
InsertSpriteCharRanges(Glossary.Goblins, 29, 3, "LMNOPQRSTUV")
InsertSpriteCharRanges(Glossary.Goblins, 29, 3, "lmnopqrstuv")
InsertSpriteCharRanges(Glossary.Goblins, 29, 4, "WXYZ0123456")
InsertSpriteCharRanges(Glossary.Goblins, 29, 4, "wxyz0123456")
InsertSpriteCharRanges(Glossary.Goblins, 27, 5, "-.789@!?")