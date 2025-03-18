
function Lerp(a, b, t)
	return a + (b - a) * t
end

function LerpColor(color, target, t)
	local r = Lerp( color.r, target.r, t)
	local g = Lerp( color.g, target.g, t)
	local b = Lerp( color.b, target.b, t)

	return Color(r, g, b, color.a)
end