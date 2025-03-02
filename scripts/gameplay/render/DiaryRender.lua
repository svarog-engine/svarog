
local DiaryRenderSystem = Engine.RegisterUIRenderSystem("Diary Render");

function DiaryRenderSystem.Render(ui)
	ui.PushBox(1, Config.Height - 2, Config.Width, 2)
		ui.PushOrder("|")
			local diary = DiaryEntity[Diary]
			ui.Label(diary.log[diary.index])
		ui.PopOrder()
	ui.PopBox()
end
