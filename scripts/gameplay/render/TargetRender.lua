local TargetRenderSystem, TargetUI = Engine.RegisterUIRenderSystem("Target Render")

local TargetOverlayActive = false
local OnTargetSelected = nil

local function CanTarget(x, y)
	local visit = Dungeon.visibility:Has(x, y) and Dungeon.visibility:Get(x, y)
	local pass = Dungeon.passable:Has(x, y) and Dungeon.passable:Get(x, y)
	return visit and pass
end

TargetUI:Set(Position{ x = 0, y = 0 })

function TargetRenderSystem.UIRender(ui)
	local x, y = PlayerEntity[Position].x, PlayerEntity[Position].y 
	local mx, my = TargetUI[Position].x, TargetUI[Position].y
	ui.Line(x, y, mx, my, Colors.White, CanTarget)
end

function TargetRenderSystem:ShouldRender()
	return TargetOverlayActive
end

function TargetRenderSystem:Activate(onTargetSelectedCallback)
	Input.Push("TargetOverlay")
	TargetOverlayActive = true
	OnTargetSelected = onTargetSelectedCallback
end

function TargetRenderSystem:Deactivate(isCanceled)
	TargetOverlayActive = false
	Input.Pop()
end

function TargetRenderSystem:UpdatePosition(dx, dy)
	local pos = TargetUI[Position]

	local deltaX = dx or 0
	local deltaY = dy or 0

	pos.x = pos.x + deltaX
	pos.y = pos.y + deltaY
end

function TargetRenderSystem:SetPosition(x, y)
	local pos = TargetUI[Position]

	pos.x = x
	pos.y = y
end