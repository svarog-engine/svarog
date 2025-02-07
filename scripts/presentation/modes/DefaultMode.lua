
Glossary.Meta.Default = FontPresentationMode("whitrabt", 14, true)

Glossary.Default = {
	goblin = { char = "g", fg = Colors.LightGreen, bg = Colors.Black },
	kobold = { char = "k", fg = Colors.LightRed, bg = Colors.Black },

	player = { char = "@", fg = Colors.LightBlue, bg = Colors.Black },
	pet = { char = "d", fg = Colors.LightYellow, bg = Colors.Black },
	
	mage = { char = "@", fg = Colors.LightBlue, bg = Colors.Black },
	monk = { char = "@", fg = Colors.LightBlue, bg = Colors.Black },

	door_closed = { char = "+", fg = Colors.White, bg = Colors.Black },
	door_open = { char = "_", fg = Colors.White, bg = Colors.Black },

	back_dark = { char = ".", fg = Colors.Gray, bg = Colors.Black },
	back_semi = { char = ".", fg = Colors.LightGray, bg = Colors.Black },
	back_mid = { char = ".", fg = Colors.LightGray, bg = Colors.Black },
	back_lit = { char = ".", fg = Colors.White, bg = Colors.Black },

	empty_tile = { char = ".", fg = Colors.Gray, bg = Colors.Black },

	wall = { char = "#", fg = Colors.DarkGray, bg = Colors.Black },
	
	missing = { char = " ", fg = Colors.White, bg = Colors.Black },
	treasure = { char = "$", fg = Colors.LightYellow, bg = Colors.Black },

	item = {char = "i", fg = Colors.Yellow, bg = Colors.Black},
	key = {char = "-", fg = Colors.Yellow, bg = Colors.Black},

	empty =  { char = " ", fg = Colors.White, bg = Colors.Black },
	invalid = { char = "", fg = Colors.Transparent, bg = Colors.Transparent},
}

InsertFontAlphanumerics(Glossary.Default)