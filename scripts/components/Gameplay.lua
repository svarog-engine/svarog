
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

-- Challenge

Challenged = ECS.Component()

MagicChallenge = ECS.Component { time = 0, difficulty = 0 }

Platform = ECS.Component { challenge = nil }

-- Tension

Tension = ECS.Component(Range(9, 9))

function Tension:Up(n)
	if self.current < self.maximum then
		self.current = self.current + (n or 1)

		if self.current >= self.maximum then
			self.current = self.maximum
			PlayerEntity:Set(Challenged())
		end
	end
end

function Tension:Down(n)
	self.current = self.current - (n or 1)
end

TensionIncrease = ECS.Component { value = 0 }
TensionLocked = ECS.Component()
TensionDecrease = ECS.Component { value = 0 }
TensionLimitReached = ECS.Component()
