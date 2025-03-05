
local PlayerInfoRenderSystem = Engine.RegisterUIRenderSystem("Player Info Render");

local Components = { 
	Health = Health, 
	Telepathic = Telepathic, 
	Invisible = Invisible,
	Delayed = Delayed,
}

function PlayerInfoRenderSystem.Render(ui)
	local player = PlayerEntity
	if player == nil then
		return
	end

	UIRenderer.ClearBox(47, 2, 20, 20)

	ui.PushBox(47, 2, 20, 20)
		ui.PushOrder("|")
			for name, comp in pairs(Components) do
				local v = player[comp]
				if v ~= nil then
					ui.Bar(name, v.current, v.maximum, { width = v.maximum })
				end
			end
		ui.PopOrder()
	ui.PopBox()
end
