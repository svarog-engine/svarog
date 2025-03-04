
local PlayerInfoRenderSystem = Engine.RegisterUIRenderSystem("Player Info Render");

function PlayerInfoRenderSystem.Render(ui)
	local player = PlayerEntity
	if player == nil then
		return
	end

	local health = player[Health]
	local telepathic = player[Telepathic]

	ui.PushBox(47, 2, 20, 20)
		ui.PushOrder("|")

			if health ~= nil then
				ui.Bar("Health", health.current, health.maximum, { width = 10 })
			end

			if telepathic ~= nil then
				ui.Bar("Telepathic", telepathic.turnsLeft, telepathic.duration, { width = 10 })
			end

		ui.PopOrder()
	ui.PopBox()
end
