
Player = ECS.Component()
Bump = ECS.Component({ x = 0, y = 0, dx = 0, dy = 0 })
Bumped = ECS.Component({ by = 0 })

Floor = ECS.Component()
Door = ECS.Component({ closed = true, locked = false })

Position = ECS.Component({ x = 0, y = 0 })
MoveTo = ECS.Component({ x = 0, y = 0 })

MakeDungeonRequest = ECS.Component()

Dungeon = ECS.Component({ map = {} })
DungeonEntity = World:Entity(Dungeon({ map = {} }))