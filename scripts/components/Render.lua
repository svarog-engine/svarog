
Glyph = ECS.Component{ char = " ", fg = nil, bg = nil }
FadeOut = ECS.Component{ start = nil, target = nil, time = 0, speed = 0.1 }

function Fade(entity, start, target, speed)
	if speed == nil then speed = 0.1 end
	entity:Set(FadeOut{ start = start, target = target, time = 0, speed = speed })
end

function PCExplode(limit, fg, bg, callback)
	PlayerEntity:Set(VFXExplosion{ current = 0, maximum = limit, fg = fg, bg = bg, callback = callback })
end
