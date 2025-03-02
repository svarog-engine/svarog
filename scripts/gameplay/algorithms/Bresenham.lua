
local function PlotLineHigh(startX, startY, endX, endY, color, isVisibleFn)
	local dx = endX - startX
	local dy = endY - startY

	local xi = 1
	if dx < 0 then
		xi = -1
		dx = -dx
	end

	local D = (2 * dx) - dy
	local x = startX

	for y = startY, endY do
		
		if isVisibleFn(x, y) then
			Engine.Glyph(x, y, nil, { bg = color })
		end

		if D > 0 then
			x = x + xi
			D = D + (2 * (dx - dy))
		else
			D = D + 2*dx
		end
	end
end

local function PlotLineLow(startX, startY, endX, endY, color, isVisibleFn)
	local dx = endX - startX
	local dy = endY - startY

	local yi = 1
	if dy < 0 then
		yi = -1
		dy = -dy
	end

	local D = (2 * dy) - dx
	local y = startY

	for x = startX, endX do

		if isVisibleFn(x, y) == true then
			Engine.Glyph(x, y, nil, { bg = color })
		end

		if D > 0 then
			y = y + yi
			D = D + (2 * (dy - dx))
		else
			D = D + 2*dy
		end
	end
end

local FT = function(x, y) return true end

function PlotLine(startX, startY, endX, endY, color, isVisibleFn)
	if isVisibleFn == nil then isVisibleFn = FT end
	if math.abs(endY - startY) < math.abs(endX - startX) then
		if startX > endX then
			PlotLineLow(endX, endY, startX, startY, color, isVisibleFn)
		else
			PlotLineLow(startX, startY, endX, endY, color, isVisibleFn)
		end
	else
		if startY > endY then
			PlotLineHigh(endX, endY, startX, startY, color, isVisibleFn)
		else
			PlotLineHigh(startX, startY, endX, endY, color, isVisibleFn)
		end
	end
end
