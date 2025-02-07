
Glossary.Meta.Kenney = SpritePresentationMode("kenney-16x16.png", 16, 49)

Glossary.Kenney = {
	goblin = { x = 30, y = 3, fg = Colors.LightGreen, bg = Colors.Black },
	kobold = { x = 26, y = 3, fg = Colors.LightRed, bg = Colors.Black },
	
	player = { x = 42, y = 22, fg = Colors.LightBlue, bg = Colors.Black },
	pet = { x = 31, y = 7, fg = Colors.LightYellow, bg = Colors.Black },

	mage = { x = 24, y = 2, fg = Colors.LightBlue, bg = Colors.Black },
	monk = { x = 25, y = 1, fg = Colors.LightBlue, bg = Colors.Black },

	door_open = { x = 9, y = 9, fg = Colors.Gray, bg = Colors.Black },
	door_closed = { x = 10, y = 9, fg = Colors.Gray, bg = Colors.Black },

	back_dark = { x = 46, y = 17, fg = Colors.DarkBrown, bg = Colors.Black },
	back_semi = { x = 1, y = 0, fg = Colors.Brown, bg = Colors.Black },
	back_mid = { x = 2, y = 0, fg = Colors.Brown, bg = Colors.Black },
	back_lit = { x = 4, y = 0, fg = Colors.Brown, bg = Colors.Black },

	empty_tile = { x = 28, y = 22, fg = Colors.DarkGray, bg = Colors.Black },

	wall = { x = 11, y = 18, fg = Colors.Gray, bg = Colors.Black },
	treasure = { x = 32, y = 16, fg = Colors.LightYellow, bg = Colors.Black },
	item = { x = 32, y = 7, fg = Colors.Yellow, bg = Colors.Black },
	key = { x = 32, y = 11, fg = Colors.Yellow, bg = Colors.Black },

	empty = { x = 28, y = 22, fg = Colors.DarkGray, bg = Colors.Black },
	invalid = { x = -1, y = -1, fg = Colors.Transparent, bg = Colors.Transparent},
}

InsertSpriteCharRanges(Glossary.Kenney, 0, 0, " ")
InsertSpriteCharRanges(Glossary.Kenney, 35, 16, "$")
InsertSpriteCharRanges(Glossary.Kenney, 35, 17, "0123456789:.%")
InsertSpriteCharRanges(Glossary.Kenney, 35, 18, "abcdefghijklm")
InsertSpriteCharRanges(Glossary.Kenney, 35, 18, "ABCDEFGHIJKLM")
InsertSpriteCharRanges(Glossary.Kenney, 35, 19, "nopqrstuvwxyz")
InsertSpriteCharRanges(Glossary.Kenney, 35, 19, "NOPQRSTUVWXYZ")
InsertSpriteCharRanges(Glossary.Kenney, 35, 20, "#+-")
InsertSpriteCharRanges(Glossary.Kenney, 40, 20, "=@")