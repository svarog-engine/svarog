
-- Outer Circle

Open = ECS.Component { level = 1 }
Uncover = ECS.Component { level = 1 }
Enlarge = ECS.Component { level = 1 }
Flow = ECS.Component { level = 1 }
Calm = ECS.Component { level = 1, chance = 8 }
Rage = ECS.Component { level = 1 }
Yearn = ECS.Component { level = 1, chance = 2 }
Discover = ECS.Component { level = 1 }
Heal = ECS.Component { level = 1, chance = 3 }
Endure = ECS.Component { level = 1, turns = 8 }
Luck = ECS.Component { level = 1, chance = 5, multiplier = 2 }
Fade = ECS.Component { level = 1 }

-- Inner Circle

Alarm = ECS.Component { level = 1 }
Identify = ECS.Component { level = 1 }
Stop = ECS.Component { level = 1 }
Darken = ECS.Component { level = 1 ,chance = 8 }
Frighten = ECS.Component { level = 1 }
Store = ECS.Component { level = 1 }
Light = ECS.Component { level = 1, chance = 8, bonusRadius = 5 }
Strengthen = ECS.Component { level = 1 }
Steal = ECS.Component { level = 1 }
Learn = ECS.Component { level = 1 }
Weaken = ECS.Component { level = 1 }
Break = ECS.Component { level = 1, chance = 8 }

-- Metals

Metallic = ECS.Component()
Steel = ECS.Component()
Iron = ECS.Component()
Silver = ECS.Component()
Darkore = ECS.Component()

-- Herbs

Herb = ECS.Component { name = "", element = nil }
Mineral = ECS.Component { name = "", element = nil }
