using SFML.Window;

using svarog.src.windowing;

using System.Numerics;

namespace svarog.src.tools
{
    public class ImageSampler : ITool
    {
        Svarog m_Svarog;
        int m_GridSize;
        float m_Scale = 2;
        //GLImGuiTexture m_Texture;
        HashSet<Vector2> m_Selection = new();
        Vector2 m_Start;
        Vector2 m_End;
        bool m_Open = true;
        bool m_Grid = true;
        bool m_IsDragging = false;
        bool m_DragChange = false;

        public ImageSampler(Svarog svarog, string image, int gridSize, float scale) 
        {
            Name = image;
            m_Svarog = svarog;
            m_GridSize = gridSize;
            m_Scale = scale;

            //m_Texture = svarog.ToolBox.GetImguiTexture(image);
        }

        public string Name { get; set; }

        public void Render(IWindow window)
        {
            //ImGui.SetNextWindowSize(new System.Numerics.Vector2(m_Scale * m_Texture.Width + 25, m_Scale * m_Texture.Height + 100), ImGuiCond.Always);
            
            //if (ImGui.Window(Name, ref m_Open, ImGuiWindowFlags.NoResize))
            //{
            //    var keyboard = window.GetKeyboard();

            //    var grid = m_Grid ? "x" : " ";
            //    if (ImGui.Button($"Grid [{grid}]##GridOn")) { m_Grid = !m_Grid; }
            //    ImGui.SameLine();
            //    if (ImGui.Button("1x")) { m_Scale = 1; }
            //    ImGui.SameLine();
            //    if (ImGui.Button("2x")) { m_Scale = 2; }

            //    var xy = ImGui.GetCursorPos();
            //    ImGui.Image(m_Texture.GLTexture, new System.Numerics.Vector2(m_Texture.Width * m_Scale, m_Texture.Height * m_Scale));

            //    if (m_GridSize > 0)
            //    {
            //        var pos = ImGui.GetWindowPos() + xy;
            //        var drawlist = ImGui.GetWindowDrawList();
            //        if (m_Grid)
            //        {
            //            for (int i = 0; i <= m_Texture.Width / m_GridSize; i++)
            //            {
            //                drawlist.AddLine(new System.Numerics.Vector2(pos.X + i * m_GridSize * m_Scale, pos.Y), new System.Numerics.Vector2(pos.X + i * m_GridSize * m_Scale, pos.Y + m_Texture.Height * m_Scale), ImGui.GetColorU32(ImGuiCol.PlotLines));
            //            }

            //            for (int i = 0; i <= m_Texture.Height / m_GridSize; i++)
            //            {
            //                drawlist.AddLine(new System.Numerics.Vector2(pos.X, pos.Y + i * m_GridSize * m_Scale), new System.Numerics.Vector2(pos.X + m_Texture.Width * m_Scale, pos.Y + i * m_GridSize * m_Scale), ImGui.GetColorU32(ImGuiCol.PlotLines));
            //            }
            //        }
            //        var mouse = ImGui.GetMousePos();
                    
            //        if (ImGui.IsWindowFocused())
            //        {
            //            if (keyboard.IsJustPressed(Keyboard.Scancode.N))
            //            {
            //                ImGui.OpenPopup("NameNewSubPattern");
            //                ms_Svarog.OpenPopup = true;
            //            }

            //            if (ImGui.IsMouseDown(ImGuiMouseButton.Left))
            //            {
            //                var dxy = (mouse - pos) / (m_GridSize * m_Scale);
            //                var dx = MathF.Round(dxy.X - 0.5f);
            //                var dy = MathF.Round(dxy.Y - 0.5f);

            //                if (dx >= 0 && dy >= 0 && dx < m_Texture.Width / m_GridSize && dy < m_Texture.Height / m_GridSize)
            //                {
            //                    dxy.X = dx;
            //                    dxy.Y = dy;

            //                    if (!m_IsDragging)
            //                    {
            //                        m_Start = dxy;
            //                        m_IsDragging = true;
            //                    }
            //                    else
            //                    {
            //                        m_End = dxy;
            //                    }

            //                    drawlist.AddRectFilled(
            //                        pos + m_Start * m_GridSize * m_Scale,
            //                        pos + (m_End + Vector2.One) * m_GridSize * m_Scale,
            //                        ImGui.GetColorU32(ImGuiCol.Button));
            //                }
            //            }
            //            else
            //            {
            //                m_DragChange = m_IsDragging;
            //                m_IsDragging = false;
            //                var minx = (int)MathF.Min(m_Start.X, m_End.X);
            //                var miny = (int)MathF.Min(m_Start.Y, m_End.Y);

            //                var maxx = (int)MathF.Max(m_Start.X, m_End.X);
            //                var maxy = (int)MathF.Max(m_Start.Y, m_End.Y);

            //                if (m_DragChange && !keyboard.IsDown(Keyboard.Scancode.LControl))
            //                {
            //                    m_Selection.Clear();
            //                }

            //                for (int i = minx; i <= maxx; i++)
            //                {
            //                    for (int j = miny; j <= maxy; j++)
            //                    {
            //                        m_Selection.Add(new Vector2(i, j));
            //                    }
            //                }

            //                ms_Svarog.ToolBox.CurrentBrush = new GlyphBrush() { Name = "", Image = Name, Blocks = m_Selection };
            //            }
            //        }

            //        foreach (var square in m_Selection)
            //        {
            //            drawlist.AddRectFilled(
            //                pos + square * m_GridSize * m_Scale,
            //                pos + (square + Vector2.One) * m_GridSize * m_Scale,
            //                ImGui.GetColorU32(ImGuiCol.Button));
            //        }

            //        ImGui.End();
            //    }   
            //}
            
            //if (!m_Open)
            //{
            //    ms_Svarog.ToolBox.ShouldClose(this);
            //}
        }
    }
}
