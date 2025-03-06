InflictStatus = ECS.Component { component = nil }
ProvideStatus = ECS.Component { component = nil }

Telepathic = ECS.Component(Range(1, 1))
Invisible = ECS.Component(Range(1, 1))
Delayed = ECS.Component { damage = 0, current = 8, maximum = 8 }

Blindness = ECS.Component(Range(1, 1))