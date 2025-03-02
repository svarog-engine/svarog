
local TargetOverlayActive = false
local OnTargetSelected = nil

local TargetingToggleSystem = Engine.RegisterPlayerSystem("Targeting Toggle")

function TargetingToggleSystem:ShouldTick()
	return TargetOverlayEntity[ActivateTargetOverlay] ~= nil or 
		   TargetOverlayEntity[DeactivateTargetOverlay] ~= nil
end

function TargetingToggleSystem:Tick()
	local overlayActivation = TargetOverlayEntity[ActivateTargetOverlay]
	if overlayActivation ~= nil then
		OnTargetSelected = overlayActivation.callback
		TargetOverlayActive = true

		TargetOverlayEntity:Unset(ActivateTargetOverlay)
		Input.Push("TargetOverlay")
	else
		local result = TargetOverlayEntity[DeactivateTargetOverlay]
		if OnTargetSelected ~= nil and result.success then
			OnTargetSelected(TargetOverlayEntity[Position].x or 0, TargetOverlayEntity[Position].y or 0)
		end
		TargetOverlayActive = false
		TargetOverlayEntity:Unset(DeactivateTargetOverlay)
		Input.Pop()
	end
end

local TargetRenderSystem, TargetUIEntity = Engine.RegisterUIRenderSystem("Target Render")

local function CanTarget(x, y)
	local visit = Dungeon.visibility:Has(x, y) and Dungeon.visibility:Get(x, y)
	local pass = Dungeon.passable:Has(x, y) and Dungeon.passable:Get(x, y)
	return visit and pass
end

function TargetRenderSystem:ShouldRender()
	return TargetOverlayActive
end

function TargetRenderSystem.Render(ui)
	local x, y = PlayerEntity[Position].x, PlayerEntity[Position].y 
	local mx, my = TargetOverlayEntity[Position].x, TargetOverlayEntity[Position].y
	ui.Line(x, y, mx, my, Colors.White, CanTarget)
end
