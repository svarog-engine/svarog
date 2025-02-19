import ('svarog', 'svarog.presentation')
import ('svarog', 'svarog.procgen.geometry')
import ('SFML', 'SFML.Graphics')

Glossary = {}
Glossary.Meta = {}

function InsertSpriteCharRanges(pres, x, y, chars)
	for i = 0, #chars - 1 do 
		local char = string.sub(chars, i + 1, i + 1)
		pres[char] = { x = x + i, y = y, fg = Colors.White, bg = Colors.Black }
	end
end

function InsertFontAlphanumerics(pres)
	pres["a"] = { char = "a", fg = Colors.White, bg = Colors.Black }
	pres["b"] = { char = "b", fg = Colors.White, bg = Colors.Black }
	pres["c"] = { char = "c", fg = Colors.White, bg = Colors.Black }
	pres["d"] = { char = "d", fg = Colors.White, bg = Colors.Black }
	pres["e"] = { char = "e", fg = Colors.White, bg = Colors.Black }
	pres["f"] = { char = "f", fg = Colors.White, bg = Colors.Black }
	pres["g"] = { char = "g", fg = Colors.White, bg = Colors.Black }
	pres["h"] = { char = "h", fg = Colors.White, bg = Colors.Black }
	pres["i"] = { char = "i", fg = Colors.White, bg = Colors.Black }
	pres["j"] = { char = "j", fg = Colors.White, bg = Colors.Black }
	pres["k"] = { char = "k", fg = Colors.White, bg = Colors.Black }
	pres["l"] = { char = "l", fg = Colors.White, bg = Colors.Black }
	pres["m"] = { char = "m", fg = Colors.White, bg = Colors.Black }
	pres["n"] = { char = "n", fg = Colors.White, bg = Colors.Black }
	pres["o"] = { char = "o", fg = Colors.White, bg = Colors.Black }
	pres["p"] = { char = "p", fg = Colors.White, bg = Colors.Black }
	pres["q"] = { char = "q", fg = Colors.White, bg = Colors.Black }
	pres["r"] = { char = "r", fg = Colors.White, bg = Colors.Black }
	pres["s"] = { char = "s", fg = Colors.White, bg = Colors.Black }
	pres["t"] = { char = "t", fg = Colors.White, bg = Colors.Black }
	pres["u"] = { char = "u", fg = Colors.White, bg = Colors.Black }
	pres["v"] = { char = "v", fg = Colors.White, bg = Colors.Black }
	pres["w"] = { char = "w", fg = Colors.White, bg = Colors.Black }
	pres["x"] = { char = "x", fg = Colors.White, bg = Colors.Black }
	pres["y"] = { char = "y", fg = Colors.White, bg = Colors.Black }
	pres["z"] = { char = "z", fg = Colors.White, bg = Colors.Black }
	pres["A"] = { char = "A", fg = Colors.White, bg = Colors.Black }
	pres["B"] = { char = "B", fg = Colors.White, bg = Colors.Black }
	pres["C"] = { char = "C", fg = Colors.White, bg = Colors.Black }
	pres["D"] = { char = "D", fg = Colors.White, bg = Colors.Black }
	pres["E"] = { char = "E", fg = Colors.White, bg = Colors.Black }
	pres["F"] = { char = "F", fg = Colors.White, bg = Colors.Black }
	pres["G"] = { char = "G", fg = Colors.White, bg = Colors.Black }
	pres["H"] = { char = "H", fg = Colors.White, bg = Colors.Black }
	pres["I"] = { char = "I", fg = Colors.White, bg = Colors.Black }
	pres["J"] = { char = "J", fg = Colors.White, bg = Colors.Black }
	pres["K"] = { char = "K", fg = Colors.White, bg = Colors.Black }
	pres["L"] = { char = "L", fg = Colors.White, bg = Colors.Black }
	pres["M"] = { char = "M", fg = Colors.White, bg = Colors.Black }
	pres["N"] = { char = "N", fg = Colors.White, bg = Colors.Black }
	pres["O"] = { char = "O", fg = Colors.White, bg = Colors.Black }
	pres["P"] = { char = "P", fg = Colors.White, bg = Colors.Black }
	pres["Q"] = { char = "Q", fg = Colors.White, bg = Colors.Black }
	pres["R"] = { char = "R", fg = Colors.White, bg = Colors.Black }
	pres["S"] = { char = "S", fg = Colors.White, bg = Colors.Black }
	pres["T"] = { char = "T", fg = Colors.White, bg = Colors.Black }
	pres["U"] = { char = "U", fg = Colors.White, bg = Colors.Black }
	pres["V"] = { char = "V", fg = Colors.White, bg = Colors.Black }
	pres["W"] = { char = "W", fg = Colors.White, bg = Colors.Black }
	pres["X"] = { char = "X", fg = Colors.White, bg = Colors.Black }
	pres["Y"] = { char = "Y", fg = Colors.White, bg = Colors.Black }
	pres["Z"] = { char = "Z", fg = Colors.White, bg = Colors.Black }	
	pres["1"] = { char = "1", fg = Colors.White, bg = Colors.Black }
	pres["2"] = { char = "2", fg = Colors.White, bg = Colors.Black }
	pres["3"] = { char = "3", fg = Colors.White, bg = Colors.Black }
	pres["4"] = { char = "4", fg = Colors.White, bg = Colors.Black }
	pres["5"] = { char = "5", fg = Colors.White, bg = Colors.Black }
	pres["6"] = { char = "6", fg = Colors.White, bg = Colors.Black }
	pres["7"] = { char = "7", fg = Colors.White, bg = Colors.Black }
	pres["8"] = { char = "8", fg = Colors.White, bg = Colors.Black }
	pres["9"] = { char = "9", fg = Colors.White, bg = Colors.Black }
	pres["0"] = { char = "0", fg = Colors.White, bg = Colors.Black }
	pres["."] = { char = ".", fg = Colors.White, bg = Colors.Black }
    pres[" "] = { char = " ", fg = Colors.White, bg = Colors.Black }
end

function LoadPresentation(name)
   Svarog:RunScriptFile("scripts\\presentation\\modes\\" .. name)
end

function LoadPalette(name)
    Svarog:RunScriptFile("scripts\\presentation\\palettes\\" .. name)
end