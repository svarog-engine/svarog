using svarog.src.windowing;
using svarog.src.tools;
using SFML.Graphics;
using svarog.src.render;
using SFML.System;

namespace svarog.src
{
    static class RandomExtensions
    {
        public static void Shuffle<T>(this Random rng, List<T> array)
        {
            int n = array.Count;
            while (n > 1)
            {
                int k = rng.Next(n--);
                T temp = array[n];
                array[n] = array[k];
                array[k] = temp;
            }
        }
    }

    public class Svarog
    {
        readonly MainWindow m_GameWindow;
        public MainWindow MainWindow => m_GameWindow;

        ToolBox m_Toolbox;
        public ToolBox ToolBox => m_Toolbox;

        FileManager m_FileManager;
        GlyphRenderer m_Renderer;

        public GlyphRenderer Renderer => m_Renderer;

        static void Main(string[] args)
        {
            new Svarog("config.lua").Run(args);
        }

        public Svarog(string config)
        {
            m_GameWindow = new MainWindow(this, config);
            
            m_GameWindow.StartGame += StartGame;
            m_GameWindow.RenderGUI += RenderGUI;
            m_GameWindow.RenderGame += RenderGame;
        }

        private void StartGame(IWindow window)
        {
            m_Toolbox = new ToolBox(this);
            m_FileManager = new FileManager(this);

            m_Renderer = new(this);
        }

        private string m_NewPatternName = "";
        private int m_NewPatternX = 3;
        private int m_NewPatternY = 3;
        private int m_GridSize = 12;
        private string m_NewName = "";

        public bool OpenPopup { get; set; } = false;

        private void RenderGUI(IWindow window)
        {
            var keyboard = window.GetKeyboard();
            m_FileManager.Render(window);
            //ImGui.DockSpaceOverViewport(0, ImGui.GetMainViewport(), ImGuiDockNodeFlags.PassthruCentralNode);
            
            //if (ImGui.BeginMainMenuBar())
            //{
            //    if (ImGui.BeginMenu("Pattern"))
            //    {
            //        ImGui.SetNextItemWidth(200);
            //        ImGui.InputText("##PatternName", ref m_NewPatternName, 15);
            //        ImGui.SameLine();
            //        ImGui.Text("XY");
            //        ImGui.SameLine();
            //        ImGui.SetNextItemWidth(100);
            //        ImGui.SliderInt("##PatternX", ref m_NewPatternX, 1, 10);
            //        ImGui.SameLine();
            //        ImGui.SetNextItemWidth(100);
            //        ImGui.SliderInt("##PatternY", ref m_NewPatternY, 1, 10);
            //        ImGui.SameLine();
            //        ImGui.Text("Grid");
            //        ImGui.SameLine();
            //        ImGui.SetNextItemWidth(100);
            //        ImGui.SliderInt("##GridSize", ref m_GridSize, 8, 16);
            //        ImGui.SameLine();

            //        if (ImGui.Button("Create"))
            //        {
            //            var name = $"{m_NewPatternName}.pat";
            //            var pat = Pattern.NewPattern(m_NewPatternName, m_NewPatternX, m_NewPatternY, m_GridSize);
            //            ToolBox.UpdatePattern(m_NewPatternName, pat);
            //            ToolBox.RefreshFiles();
            //            ToolBox.OpenPatternEditor(name);
            //        }
            //        ImGui.EndMenu();
            //    }

            //    ImGui.EndMenuBar();
            //}

            //m_Toolbox.Render(window);

            //m_FileManager.Render(window);

            //if (ToolBox.CurrentBrush.HasValue && OpenPopup)
            //{
            //    m_NewName = "";
            //    OpenPopup = false;
            //    ImGui.OpenPopup("NameNewSubPattern");
            //    ImGui.SetNextWindowSize(new System.Numerics.Vector2(570, 35));
            //}

            //if (ImGui.BeginPopupModal("NameNewSubPattern", 
            //    ImGuiWindowFlags.Popup | ImGuiWindowFlags.Modal | 
            //    ImGuiWindowFlags.NoTitleBar | ImGuiWindowFlags.NoResize | 
            //    ImGuiWindowFlags.NoScrollbar))
            //{
            //    ImGui.SetItemDefaultFocus();
            //    ImGui.InputText("New Pattern", ref m_NewName, 20);
            //    ImGui.SameLine();
            //    var nameOk = m_NewName.Length > 0;
            //    if (!nameOk) ImGui.BeginDisabled();
            //    if (ImGui.Button("Save"))
            //    {
            //        var brush = ToolBox.CurrentBrush.Value;
            //        var data = ToolBox.FileData[brush.Image];
            //        var name = $"{m_NewName}.pat";
            //        var pat = Pattern.NewPattern(m_NewName, (int)brush.Size.X, (int)brush.Size.Y, data.Type.GridSize());
            //        var min = brush.Min;
            //        foreach (var block in brush.Blocks)
            //        {
            //            var sourceId = (int)(data.Width * block.Y + block.X);

            //            var targetXY = block - brush.Min;
            //            var targetId = (int)(targetXY.Y * pat.Width + targetXY.X);
            //            pat.Data.Add(new PatternBlock(targetId, brush.Image, sourceId));
            //        }
            //        ToolBox.UpdatePattern(m_NewName, pat);
            //        ToolBox.RefreshFiles();
            //        ToolBox.OpenPatternEditor(name);
            //        ImGui.CloseCurrentPopup();
            //    }
            //    if (!nameOk) ImGui.EndDisabled();
            //    ImGui.SameLine();
            //    if (ImGui.Button("Cancel"))
            //    {
            //        ImGui.CloseCurrentPopup();
            //    }
            //    ImGui.EndPopup();
            //}

            //if (keyboard.IsDown(SFML.Window.Keyboard.Scancode.LControl) && keyboard.IsJustPressed(SFML.Window.Keyboard.Scancode.Z))
            //{
            //    ToolBox.Undo();
            //}

            //if (keyboard.IsDown(SFML.Window.Keyboard.Scancode.LControl) && keyboard.IsJustPressed(SFML.Window.Keyboard.Scancode.Y))
            //{
            //    ToolBox.Redo();
            //}
        }

        private void RenderGame(IWindow window)
        {
            m_Renderer.Clear();
            m_Renderer.Draw(ToolBox.GetPattern("gob.pat"), new Vector2f(100, 100), 2);
            m_Renderer.Display();
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
