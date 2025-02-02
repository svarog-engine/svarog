
local LogRenderSystem = Engine.RegisterRenderSystem();

function LogRenderSystem:Render()
	for _, entity in World:Exec(ECS.Query.All(Diary)):Iterator() do
		local diary = entity[Diary]

		if diary.index > 0 then
			local message = diary.log[diary.index]
			Engine.Line(Config.Height - 2, "empty", Colors.White, Colors.Black, "UI")
			Engine.Write(1, Config.Height - 2, message, Colors.White, Colors.Black, "UI")
		end
	end
end
