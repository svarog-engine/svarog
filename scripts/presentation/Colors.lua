Colors = { }

local substring = string.sub
local toNumber = tonumber

function HexToColor(hex)
	local startIndex = 1
	if substring(hex, 1, 1) == "#" then
		startIndex = 2
	end

	local r = toNumber(substring(hex, startIndex, startIndex + 1), 16)
	local g = toNumber(substring(hex, startIndex + 2, startIndex + 3), 16)
	local b = toNumber(substring(hex, startIndex + 4, startIndex + 5), 16)
	local a = toNumber(substring(hex, startIndex + 6, startIndex + 7), 16)

	return Color(r, g, b, a or 255)
end

function Color(r, g, b, a)
	return 
	{
		r = r,
		g = g,
		b = b,
		a = a,
		engineColor = Svarog:ToEngineColor(r, g, b, a)
	}
end

function ColorToString(color)
	return "Color: [R] " .. color.r .. " [G] " .. color.g .. " [B] " .. color.b
end