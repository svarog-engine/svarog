TargetRenderSystem = Engine.RegisterRenderSystem("Target Render")

local TargetOverlayActive = false
local OnTargetSelected = nil
local SourceX = 0
local SourceY = 0

local function CanTarget(x, y)
	local ignoreFOV = not DebugToggle_FOV
	local visit = Dungeon.visibility:Has(x,y) and Dungeon.visibility:Get(x,y) == 1
	local pass = Dungeon.passable:Has(x, y) and Dungeon.passable:Get(x, y)
	return (visit or ignoreFOV) and pass
end

function TargetRenderSystem:ShouldRender()
	return TargetOverlayActive
end

function TargetRenderSystem:Render()
	local widget = UI[TargetOverlay]
	PlotLine(widget.startX, widget.startY, widget.x, widget.y, widget.trailColor, CanTarget)
	Engine.Glyph(widget.x, widget.y, nil, { bg = widget.targetColor })
end

-- OnTargetSelectedCallback can have fields: callback and data
-- This allow to have parameters in data field that can help resolve this callback on proper target (look input action for drop)
-- Callback parameters -> (x, y, data) where data is data from OnTargetSelectedCallback.data

function TargetRenderSystem:Activate(onTargetSelectedCallback, startX, startY)
	Input.Push("TargetOverlay")
	TargetOverlayActive = true
	OnTargetSelected = onTargetSelectedCallback
	local widget = UI[TargetOverlay]
	widget.startX = startX
	widget.startY = startY
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
	self.UpdatePosition()
	widget.x = 0
	widget.y = 0
end

function TargetRenderSystem:UpdatePosition(dx, dy)
	local widget = UI[TargetOverlay]

	local deltaX = dx or 0
	local deltaY = dy or 0

	if not Dungeon.floor:Has(widget.x, widget.y) then
		Engine.Glyph(widget.x, widget.y, nil, { bg = Colors.Black })
	end

	widget.x = widget.x + deltaX
	widget.y = widget.y + deltaY
end

function TargetRenderSystem:SetPosition(x, y)
	local widget = UI[TargetOverlay]

	if not Dungeon.floor:Has(x, y) then
		Engine.Glyph(widget.x, widget.y, nil, { bg = Colors.Black })
	end

	widget.x = x
	widget.y = y
end