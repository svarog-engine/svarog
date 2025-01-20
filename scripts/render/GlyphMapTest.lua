
local alp = "thequickbrownfoxjumpsoverthelazydog"
	
Engine.OnStartup(function()
	for i = 0, Options.WorldWidth - 1 do
		for j = 0, Options.WorldHeight - 1 do
			Glyphs[i][j].Presentation = Rand:From(alp)
			Glyphs[i][j].Foreground = Rand:Color()
			Glyphs[i][j].Background = Rand:Color()
		end
	end
end)

table.insert(Pipeline_Render, ECS.System(
	Engine.RenderSystem(), 
	ECS.Query.All(RenderChangelist), 
	function(self)
		self:Result():ForEach(function(entity)
			for i, c in ipairs(entity[RenderChangelist].changes) do
				print(i, c)
			end
		end)
	end
))
