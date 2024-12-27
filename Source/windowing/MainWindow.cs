using ImGuiNET;

using Lua;

using OpenTK.Graphics.OpenGL;
using OpenTK.Windowing.Desktop;

using SFML.Graphics;
using SFML.System;
using SFML.Window;

using svarog.Source.imgui;

namespace svarog.Source.windowing
{
    public class MainWindow : IWindow
    {
        VideoMode m_VideoMode = VideoMode.DesktopMode;
        string m_Title = "Svarog";

        readonly inputs.Keyboard m_Keyboard;
        readonly inputs.Mouse m_Mouse;

        uint m_Framerate = 120;
        bool m_KeyRepeat = false;
        bool m_ToolsVisible = false;

        RenderWindow? m_Window = null;
        GameWindow m_GLWindow;
        ImGuiController m_ImGui;
        Clock m_Clock;

        int m_Width;
        int m_Height;

        string m_ConfigFile;

        readonly LuaState m_Scripting;
        public LuaState Scripting => m_Scripting;

        public event Action<IWindow> StartGame;
        public event Action<IWindow> RenderGame;
        public event Action<IWindow> RenderGUI;

        public MainWindow(string configFile)
        {
            m_Scripting = LuaState.Create();

            m_ConfigFile = configFile;

            m_Keyboard = new inputs.Keyboard();
            m_Mouse = new inputs.Mouse();
            m_Clock = new Clock();

            var context = m_Scripting;
            context.Environment["config"] = new LuaTable();
            context.Environment["config"].Read<LuaTable>()["window"] = new LuaTable();
        }

        public void Make()
        {
            var context = m_Scripting;

            Task.WaitAny(Task.Run(async () => await context.DoFileAsync(m_ConfigFile)));

            var config = context.Environment["config"].Read<LuaTable>();
            var window = config["window"].Read<LuaTable>();
            if (window["width"].TryRead(out double w) && window["height"].TryRead(out double h))
            {
                m_Width = (int)w;
                m_Height = (int)h;
            }

            GameWindowSettings glWindowSettings = new GameWindowSettings();
            NativeWindowSettings glNativeWindowSettings = new NativeWindowSettings();
            glNativeWindowSettings.StartVisible = false;
            m_GLWindow = new GameWindow(glWindowSettings, glNativeWindowSettings);
            m_VideoMode = new SFML.Window.VideoMode((uint)m_Width, (uint)m_Height);

            if (window["title"].TryRead(out string title))
            {
                m_Title = title;
            }

            if (window["framerate"].TryRead(out double framerate))
            {
                m_Framerate = (uint)framerate;
            }

            if (window["key_repeat"].TryRead(out bool keyRepeat))
            {
                m_KeyRepeat = keyRepeat;
            }

            m_Title = title;
            
            m_Window = new RenderWindow(m_VideoMode, m_Title);
            m_Window.SetKeyRepeatEnabled(false);
            m_Window.SetFramerateLimit(60);

            m_Window.KeyPressed += (sender, e) => m_Keyboard.InputDown(e.Scancode);
            m_Window.KeyReleased += (sender, e) => m_Keyboard.InputUp(e.Scancode);
            m_Window.MouseMoved += (sender, e) => m_Mouse.Move(e.X, e.Y);
            m_Window.MouseButtonPressed += (sender, e) => m_Mouse.InputDown(e.Button);
            m_Window.MouseButtonReleased += (sender, e) => m_Mouse.InputUp(e.Button);
            m_Window.Closed += (window, _) => m_Window.Close();
            m_Window.Resized += Window_Resized;

            m_GLWindow.Size = new OpenTK.Mathematics.Vector2i((int)m_Window.Size.X, (int)m_Window.Size.Y);
            m_GLWindow.Location = new OpenTK.Mathematics.Vector2i(m_Window.Position.X, m_Window.Position.Y);
            m_ImGui = new ImGuiController((int)m_Window.Size.X, (int)m_Window.Size.Y);
            
            ImGui.GetIO().ConfigWindowsMoveFromTitleBarOnly = true;
            ImGui.GetIO().ConfigFlags |= ImGuiConfigFlags.DockingEnable;

            StartGame?.Invoke(this);
        }

        private void Window_Resized(object? sender, SizeEventArgs e)
        {
            GL.Viewport(0, 0, (int)e.Width, (int)e.Height);
            m_ImGui.WindowResized((int)e.Width, (int)e.Height);
        }

        public bool Frame()
        {
            if (m_Window == null) return false;

            var time = m_Clock.Restart();
            m_ImGui.Update(ref m_Window, time.AsSeconds());

            m_Window.DispatchEvents();
            if (m_Keyboard.IsJustReleased(Keyboard.Scancode.Tab))
            {
                m_ToolsVisible = !m_ToolsVisible;
            }

            m_Window.Clear();

            RenderGame?.Invoke(this);

            if (m_ToolsVisible)
            {
                GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit | ClearBufferMask.StencilBufferBit);
                RenderGUI?.Invoke(this);

                m_ImGui.Render();
                m_GLWindow.SwapBuffers();
            }

            m_Window.Display(); 

            m_Keyboard.Frame();
            m_Mouse.Frame();

            Thread.Yield();

            return m_Window.IsOpen;
        }

        public inputs.Keyboard GetKeyboard()
        {
            return m_Keyboard;
        }

        public inputs.Mouse GetMouse()
        {
            return m_Mouse;
        }
    }
}
