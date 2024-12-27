using SFML.Graphics;
using SFML.Window;
using Lua;
using Lua.Standard;
using SFML.System;
using svarog.Source.windowing;
using OpenTK.Windowing.GraphicsLibraryFramework;
using OpenTK.Graphics.OpenGL;
using ImGuiNET;
using svarog.Source.imgui;
using System.Drawing;
using SadRex;
using svarog.Source.tools;

namespace svarog.Source
{
    public class Svarog
    {
        MainWindow m_GameWindow;
        ImageSampler m_Sampler;

        static void Main(string[] args)
        {
            new Svarog("config.lua").Run(args);
        }

        public Svarog(string config)
        {
            m_GameWindow = new MainWindow(config);
            m_GameWindow.StartGame += StartGame;
            m_GameWindow.RenderGUI += RenderGUI;
        }

        private void StartGame(IWindow window)
        {
            m_Sampler = new ImageSampler("MRMOGOB.png", 12, 2);
        }

        private void RenderGUI(IWindow window)
        {
            ImGui.DockSpaceOverViewport(0, ImGui.GetMainViewport(), ImGuiDockNodeFlags.PassthruCentralNode);
            m_Sampler.Render(window);
        }

        public void Run(string[] args)
        {
            m_GameWindow.Make();
            
            while (m_GameWindow.Frame())
            {
                Thread.Yield();
            }
        }
    }
}
