using ImGuiNET;

using SFML.Window;

using svarog.Source.imgui;
using svarog.Source.windowing;

using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace svarog.Source.tools
{
    public class ImageSampler
    {
        string m_Name;
        int m_GridSize;
        float m_Scale;
        GLImGuiTexture m_Texture;
        HashSet<Vector2> m_Selection = new();
        Vector2 m_Start;
        Vector2 m_End;

        bool m_IsDragging = false;
        bool m_DragChange = false;

        public ImageSampler(string image, int gridSize, float scale) 
        {
            m_Name = image;
            m_GridSize = gridSize;
            m_Scale = scale;

            using (var bitmap = new Bitmap(image))
            {
                m_Texture = new GLImGuiTexture(image, bitmap, true, true);
                m_Texture.SetMinFilter(OpenTK.Graphics.OpenGL4.TextureMinFilter.Nearest);
                m_Texture.SetMagFilter(OpenTK.Graphics.OpenGL4.TextureMagFilter.Nearest);
            }
        }

        public void Render(IWindow window)
        {
            ImGui.SetNextWindowSize(new System.Numerics.Vector2(m_Scale * m_Texture.Width + 25, m_Scale * m_Texture.Height + 50), ImGuiCond.FirstUseEver);
            ImGui.Begin(m_Name);
            var xy = ImGui.GetCursorPos();
            ImGui.Image(m_Texture.GLTexture, new System.Numerics.Vector2(m_Texture.Width * m_Scale, m_Texture.Height * m_Scale));

            var pos = ImGui.GetWindowPos() + xy;
            var drawlist = ImGui.GetWindowDrawList();
            for (int i = 0; i <= m_Texture.Width / m_GridSize; i++)
            {
                drawlist.AddLine(new System.Numerics.Vector2(pos.X + i * m_GridSize * m_Scale, pos.Y), new System.Numerics.Vector2(pos.X + i * m_GridSize * m_Scale, pos.Y + m_Texture.Height * m_Scale), ImGui.GetColorU32(ImGuiCol.PlotLines));
            }

            for (int i = 0; i <= m_Texture.Height / m_GridSize; i++)
            {
                drawlist.AddLine(new System.Numerics.Vector2(pos.X, pos.Y + i * m_GridSize * m_Scale), new System.Numerics.Vector2(pos.X + m_Texture.Width * m_Scale, pos.Y + i * m_GridSize * m_Scale), ImGui.GetColorU32(ImGuiCol.PlotLines));
            }

            var mouse = ImGui.GetMousePos();
            drawlist.AddCircle(mouse, 5, ImGui.GetColorU32(ImGuiCol.PlotLines));

            if (ImGui.IsMouseDown(ImGuiMouseButton.Left))
            {
                var dxy = (mouse - pos) / (m_GridSize * m_Scale);
                var dx = MathF.Abs(MathF.Round(dxy.X - 0.5f));
                var dy = MathF.Abs(MathF.Round(dxy.Y - 0.5f));
                dxy.X = dx;
                dxy.Y = dy;

                if (!m_IsDragging)
                {
                    m_Start = dxy;
                    m_IsDragging = true;
                }
                else
                {
                    m_End = dxy;
                }

                drawlist.AddRectFilled(
                    pos + m_Start * m_GridSize * m_Scale, 
                    pos + (m_End + Vector2.One) * m_GridSize * m_Scale, 
                    ImGui.GetColorU32(ImGuiCol.Button));
            }
            else
            {
                m_DragChange = m_IsDragging;
                m_IsDragging = false;
                var minx = (int)MathF.Min(m_Start.X, m_End.X);
                var miny = (int)MathF.Min(m_Start.Y, m_End.Y);
                
                var maxx = (int)MathF.Max(m_Start.X, m_End.X);
                var maxy = (int)MathF.Max(m_Start.Y, m_End.Y);

                if (m_DragChange && !window.GetKeyboard().IsDown(Keyboard.Scancode.LControl))
                {
                    m_Selection.Clear();
                }

                for (int i = minx; i <= maxx; i++)
                {
                    for (int j = miny; j <= maxy; j++)
                    {
                        m_Selection.Add(new Vector2(i, j));
                    }
                }
            }

            foreach (var square in m_Selection)
            {
                drawlist.AddRectFilled(
                    pos + square * m_GridSize * m_Scale, 
                    pos + (square + Vector2.One) * m_GridSize * m_Scale, 
                    ImGui.GetColorU32(ImGuiCol.Button));
            }

            ImGui.End();

            if (window.GetKeyboard().IsJustPressed(Keyboard.Scancode.N))
            {
                foreach (var square in m_Selection)
                {
                    Console.WriteLine(square);
                }
            }
        }
    }
}
