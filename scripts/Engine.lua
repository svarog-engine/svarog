﻿World = ECS.World()

Actions = {}

Pipeline_Startup = {}
Pipeline_Player = {}
Pipeline_Enviro = {}
Pipeline_Render = {}

RenderChangelist = ECS.Component({ changes = {} })
Changes = World:Entity(RenderChangelist())

local FrameCount = 0

local function Update(time)
    World:Update("process", time)
    World:Update("transform", time)
    World:Update("render", time)
end

local function NextFrame()
    FrameCount = FrameCount + 1
    Update(FrameCount)
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

function OnStartup(fun) 
    table.insert(Pipeline_Startup, fun)
end

return {
    Setup = Setup,
    Frame = function() return FrameCount end,
    Update = NextFrame,
    PlayerSystem = PlayerSystem,
    WorldSystem = WorldSystem,
    RenderSystem = RenderSystem,
    OnStartup = OnStartup,
}