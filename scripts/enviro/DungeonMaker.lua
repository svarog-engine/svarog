
Dungeon = ECS.Component({ map = {} })
DungeonEntity = World:Entity(Dungeon({ map = {} }))
CreateDungeon = ECS.Component()

local DungeonMakerSystem = Engine.RegisterEnviroSystem()

function DungeonMakerSystem:Update()
	for _, e in World:Exec(ECS.Query.All(CreateDungeon)):Iterator() do
		self.map = {}
		for i = 5, 15 do
			for j = 6, 12 do
				table.insert(self.map, { x = i, y = j, type = ".", pass = true })
			end
		end

		for i = 4, 16 do
			table.insert(self.map, { x = i, y = 5, type = "#", pass = false })
			table.insert(self.map, { x = i, y = 13, type = "#", pass = false })
		end

		for i = 5, 13 do
			table.insert(self.map, { x = 4, y = i, type = "#", pass = false })
			table.insert(self.map, { x = 16, y = i, type = "#", pass = false })
		end
		
		DungeonEntity[Dungeon].map = self.map
		e[CreateDungeon] = nil
	end
end
