
local DungeonMakerSystem = Engine.RegisterEnviroSystem()

function DungeonMakerSystem:MakeDoor(x, y, closed, locked)
	if closed == nil then closed = true end
	if locked == nil then locked = false end

	local char = "+"

	if not closed then 
		locked = false
		char = "_" 
	end

	self.floor:Set(x, y, { 
		type = Door, 
		pass = false, 
		entity = World:Entity(
			Glyph{ char = char },
			Door{ 
				closed = closed, 
				locked = locked
			}, 
			Position{ x = x, y = y }
		)
	})
end

function DungeonMakerSystem:Update()
	for _, e in World:Exec(ECS.Query.All(MakeDungeonRequest)):Iterator() do
		self.floor = Map:New(Config.WorldWidth, Config.WorldHeight)
		
		for i = 5, 15 do
			for j = 6, 12 do
				self.floor:Set(i, j, { type = Floor, pass = true })
			end
		end

		self:MakeDoor(8, 13)
		self:MakeDoor(13, 13, true, true)

		DungeonEntity[Dungeon].map = self.floor
		e[MakeDungeonRequest] = nil
	end
end
