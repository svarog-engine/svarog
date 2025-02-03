TargetRenderSystem = Engine.RegisterRenderSystem()

local TargetOverlayActive = false
local OnTargetSelected = nil
local SourceX = 0
local SourceY = 0

local function PlotLineHigh(startX, startY, endX, endY, color)
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
		Engine.Glyph(x, y, nil, { bg = color })
		if D > 0 then
			x = x + xi
			D = D + (2 * (dx - dy))
		else
			D = D + 2*dx
		end
	end
end

local function PlotLineLow(startX, startY, endX, endY, color)
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
		Engine.Glyph(x, y, nil, { bg = color })
		if D > 0 then
			y = y + yi
			D = D + (2 * (dy - dx))
		else
			D = D + 2*dy
		end
	end
end


local function PlotLine(startX, startY, endX, endY, color)
	if math.abs(endY - startY) < math.abs(endX - startX) then
		if startX > endX then
			PlotLineLow(endX, endY, startX, startY, color)
		else
			PlotLineLow(startX, startY, endX, endY, color)
		end
	else
		if startY > endY then
			PlotLineHigh(endX, endY, startX, startY, color)
		else
			PlotLineHigh(startX, startY, endX, endY, color)
		end
	end
end

function TargetRenderSystem:Render()
	if TargetOverlayActive then
		local widget = UI[TargetOverlay]
		PlotLine(SourceX, SourceY, widget.x, widget.y, widget.trailColor)
		Engine.Glyph(widget.x, widget.y, nil, { bg = widget.targetColor })
	end
end

-- OnTargetSelectedCallback can have fields: callback and data
-- This allow to have parameters in data field that can help resolve this callback on proper target (look input action for drop)
-- Callback parameters -> (x, y, data) where data is data from OnTargetSelectedCallback.data

function TargetRenderSystem:Activate(onTargetSelectedCallback, startX, startY)
	Input.Push("TargetOverlay")
	TargetOverlayActive = true
	OnTargetSelected = onTargetSelectedCallback
	local widget = UI[TargetOverlay]
	SourceX = startX
	SourceY = startY
	widget.x = startX
	widget.y = startY
end

function TargetRenderSystem:Deactivate(isCanceled)
	Input.Pop()

	TargetOverlayActive = false
	local widget = UI[TargetOverlay]
	if isCanceled == false then
		local data = OnTargetSelected["data"]
		local callback = OnTargetSelected["callback"]
		if callback ~= nil then
			callback(widget.x, widget.y, data)
		end
	end

	widget.x = 0
	widget.y = 0
end