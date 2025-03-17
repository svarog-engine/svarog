
local DiaryRenderSystem = Engine.RegisterUIRenderSystem("Diary Render");

local defaultMessageCount = 4
local expandedMessageCount = 20

local messageCount = defaultMessageCount

local bg = Colors.Black
local fg = Colors.White

local renderHeader = false
local headerBackground = Colors.DarkGray

function DiaryRenderSystem.Render(ui)

	if renderHeader then
		UIRenderer.ClearBox(1, Config.Height - messageCount - 1, Config.Width, 1)
	end

	UIRenderer.ClearBox(1, Config.Height - messageCount, Config.Width, messageCount)

	local expanded = DiaryEntity[Expanded]
	if expanded ~= nil then
		messageCount = expandedMessageCount
		bg = Colors.Gray
		renderHeader = true
	else
		messageCount = defaultMessageCount
		bg = Colors.Black
		renderHeader = false
	end

	if renderHeader then
		local headerX = 25
		local headerY = Config.Height - messageCount - 1
		ui.FillRect(1, headerY, Config.Width, 1, headerBackground)

		ui.PushBox(headerX, headerY, Config.Width, 1)
			ui.PushStyle(fg, headerBackground)
				ui.Label("= DIARY =")
			ui.PopStyle()
		ui.PopBox()
	end

	ui.FillRect(1, Config.Height - messageCount, Config.Width, messageCount, bg)

	ui.PushBox(1, Config.Height - messageCount, Config.Width, messageCount)
		ui.PushOrder("|")
			ui.PushStyle(fg, bg)
				local entries = Diary.Messages(messageCount)
				ui.List(entries, 0)
			ui.PopStyle()
		ui.PopOrder()
	ui.PopBox()
end
