using Lua;

using SFML.Graphics;
using SFML.System;
using SFML.Window;

namespace svarog.src.windowing
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
        public RenderWindow? Window => m_Window;

        Clock m_Clock;

        int m_Width;
        int m_Height;

        public int Width => m_Width;
        public int Height => m_Height;

        string m_ConfigFile;

        readonly LuaState m_Scripting;
        readonly Svarog m_Svarog;
        public LuaState Scripting => m_Scripting;

        public event Action<IWindow>? StartGame;
        public event Action<IWindow>? RenderGame;
        public event Action<IWindow>? RenderGUI;

        public MainWindow(Svarog svarog, string configFile)
        {
            m_Scripting = LuaState.Create();
            m_Svarog = svarog;

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
            if (window["width"].TryRead(out double w) && window["height"].TryRead(out double h) && window["grid"].TryRead(out double g))
            {
                m_Width = (int)(w * g);
                m_Height = (int)((h + 0.1f) * g);
            }

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

            var settings = new ContextSettings();
            settings.MajorVersion = 3;
            settings.MinorVersion = 3;
            settings.DepthBits = 24;
            settings.StencilBits = 8;
            settings.AntialiasingLevel = 2;
            settings.AttributeFlags = ContextSettings.Attribute.Default;
            m_Window = new RenderWindow(m_VideoMode, m_Title, Styles.Default, settings);
            m_Window.SetKeyRepeatEnabled(false);
            m_Window.SetFramerateLimit(60);
            
            m_Window.KeyPressed += (sender, e) => m_Keyboard.InputDown(e.Scancode);
            //m_Window.TextEntered += (sender, e) =>
            //{
            //};
            m_Window.KeyReleased += (sender, e) => m_Keyboard.InputUp(e.Scancode);
            
            m_Window.MouseMoved += (sender, e) => m_Mouse.Move(e.X, e.Y);
            m_Window.MouseButtonPressed += (sender, e) => m_Mouse.InputDown(e.Button);
            m_Window.MouseButtonReleased += (sender, e) => m_Mouse.InputUp(e.Button);
            m_Window.Closed += (window, _) =>
            {
                m_Window.Close();
            };

            m_Window.Resized += Window_Resized;
            m_Window.SetActive(true);

            //m_ImGui = new ImGuiController((int)m_Window.Size.X, (int)m_Window.Size.Y);
            
            //ImGui.GetIO().ConfigWindowsMoveFromTitleBarOnly = true;
            //ImGui.GetIO().ConfigFlags |= ImGuiConfigFlags.DockingEnable;

            StartGame?.Invoke(this);
        }

        private void Window_Resized(object? sender, SizeEventArgs e)
        {
            //GL.Viewport(0, 0, (int)e.Width, (int)e.Height);
            //m_ImGui.WindowResized((int)e.Width, (int)e.Height);
        }

        Sprite spr = new Sprite();

        public bool Frame()
        {
            if (m_Window == null) return false;

            if (m_ToolsVisible)
            {
                var time = m_Clock.Restart();
                //m_ImGui?.Update(ref m_Window, time.AsSeconds());
            }

            m_Window.DispatchEvents();
            if (m_Keyboard.IsJustReleased(Keyboard.Scancode.Tab))
            {
                m_ToolsVisible = !m_ToolsVisible;
            }

            m_Window.Clear();
            
            RenderGame?.Invoke(this);
            
            spr.Texture = m_Svarog.Renderer.Surface.Texture;
            m_Window.Draw(spr);

            if (m_ToolsVisible && m_Window.IsOpen)
            {
                RenderGUI?.Invoke(this);
                //m_ImGui?.Render();
            }

            m_Window.Display();

            m_Keyboard.Frame();
            m_Mouse.Frame();

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

        public Svarog GetCore()
        {
            return m_Svarog;
        }
    }
}
