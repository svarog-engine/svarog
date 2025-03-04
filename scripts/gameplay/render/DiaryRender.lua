
local DiaryRenderSystem = Engine.RegisterUIRenderSystem("Diary Render");

function DiaryRenderSystem.Render(ui)
	local messageCount = 3
	ui.PushBox(1, Config.Height - messageCount, Config.Width, messageCount)
		ui.PushOrder("|")
			local entries = Diary.Messages(messageCount)
			ui.List(entries, 0)
		ui.PopOrder()
	ui.PopBox()
end
