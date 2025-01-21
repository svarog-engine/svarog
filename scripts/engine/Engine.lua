World = ECS.World()

Actions = {}

Pipeline_Startup = {}
Pipeline_Player = {}
Pipeline_Enviro = {}
Pipeline_Render = {}

RenderChangelist = {}

local FrameCount = 0

local function Draw(changes)
    table.insert(RenderChangelist, changes)
end

local function RenderPass()
	for i, c in ipairs(RenderChangelist) do
		if c.Presentation ~= nil then Glyphs[c.X][c.Y].Presentation = c.Presentation end
		if c.Foreground ~= nil then Glyphs[c.X][c.Y].Foreground = c.Foreground end
		if c.Background ~= nil then Glyphs[c.X][c.Y].Background = c.Background end
	end
	RenderChangelist = {}
end

local function UpdateWorld(time)
    World:Update("process", time)
    World:Update("transform", time)
    World:Update("render", time)
    RenderPass()
end

local function NextFrame()
    FrameCount = FrameCount + 1
    UpdateWorld(FrameCount)
end

local function Setup()
    for _, v in ipairs(Pipeline_Player) do World:AddSystem(v) end
    for _, v in ipairs(Pipeline_Enviro) do World:AddSystem(v) end
    for _, v in ipairs(Pipeline_Render) do World:AddSystem(v) end
    for _, v in ipairs(Pipeline_Startup) do v() end
end

function PlayerSystem() return "process" end
function WorldSystem() return "transform" end
function RenderSystem() return "render" end

function RegisterPlayerSystem()
    local system = ECS.System(Engine.PlayerSystem())
    table.insert(Pipeline_Player, system)
    return system
end

function RegisterEnviroSystem()
    local system = ECS.System(Engine.WorldSystem())
    table.insert(Pipeline_Enviro, system)
    return system
end

function RegisterRenderSystem()
    local system = ECS.System(Engine.RenderSystem())
    table.insert(Pipeline_Render, system)
    return system
end

function RegisterInputSystem(input, fn)
    local system = ECS.System(Engine.PlayerSystem(), ECS.Query.All(input), function(self) 
        for _, e in self:Result(self.queryAction):Iterator() do
		    fn()
            Input.Consume(input)
	    end
    end)

    table.insert(Pipeline_Player, system)
end

function OnStartup(fun) 
    table.insert(Pipeline_Startup, fun)
end

return {
    Draw = Draw,
    Setup = Setup,
    Frame = function() return FrameCount end,
    Update = NextFrame,
    PlayerSystem = PlayerSystem,
    WorldSystem = WorldSystem,
    RenderSystem = RenderSystem,
    OnStartup = OnStartup,
    RegisterPlayerSystem = RegisterPlayerSystem,
    RegisterInputSystem = RegisterInputSystem
}