
Engine.OnStartup(function()
	for i = 0, Options.WorldWidth - 1 do
		for j = 0, Options.WorldHeight - 1 do
			Glyphs[i][j].Presentation = Rand:Char()
			Glyphs[i][j].Foreground = Rand:Color()
			Glyphs[i][j].Background = Rand:Color()
		end
	end
end)

