
Player = ECS.Component()
MoveMode = ECS.Component{value = ""}
Sight = ECS.Component{ radius = 5 }
Pause = ECS.Component{ duration = 0 }
Friendly = ECS.Component()
Creature = ECS.Component{ goals = {}, actions = 0, timestamp = 0 }

function TickCreature(entity)
	if Engine.Tick() > entity[Creature].timestamp then
		entity[Creature].timestamp = entity[Creature].timestamp + 1
		entity[Creature].goals = {}
	end
end

Item = ECS.Component{id = ""}

Bump = ECS.Component{ x = 0, y = 0, dx = 0, dy = 0 }
Bumped = ECS.Component{ by = 0 }

Floor = ECS.Component()
Wall = ECS.Component()

Health = ECS.Component(Range(9, 9))
BumpAttack = ECS.Component { damage = 1 }

Stamina = ECS.Component(Range(9, 9))

Platform = ECS.Component { activate = nil, canActivate = nil, removeWhenActivated = false }

-- Tension
Tension = ECS.Component(Range(9, 9))

function Tension:Up(n)
	self.current = self.current + n

	if self.current >= self.maximum then
		self.current = self.maximum
	end
end

TensionIncrease = ECS.Component { value = 0 }
TensionLocked = ECS.Component()
TensionDecrease = ECS.Component { value = 0 }
TensionLimitReached = ECS.Component()

-- Challenge

ChallengePlatform = ECS.Component()