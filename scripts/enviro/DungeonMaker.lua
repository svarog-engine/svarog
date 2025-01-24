
local DungeonMakerSystem = Engine.RegisterEnviroSystem()

function DungeonMakerSystem:Update()
	for _, e in World:Exec(ECS.Query.All(MakeDungeonRequest)):Iterator() do
		self.floor = Map:New(Config.WorldWidth, Config.WorldHeight)
		
		for i = 5, 15 do
			for j = 6, 12 do
				self.floor:Set(i, j, { type = Floor, pass = true })
			end
		end

		self.floor:Set(8, 13, { type = Door, pass = false })
		DungeonEntity[Dungeon].map = self.floor
		e[MakeDungeonRequest] = nil
	end
end
