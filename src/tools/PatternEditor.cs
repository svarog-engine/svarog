using SFML.Window;

using svarog.src.windowing;

using System.Numerics;

namespace svarog.src.tools
{
    public class PaintBrushAction : IUndoableChange
    {
        private string m_PatternName;
        private int m_Target;
        private Vector3 m_OldColor;
        private Vector3 m_NewColor;

        public PaintBrushAction(string pattern, int target, Vector3 oldColor, Vector3 newColor)
        {
            m_PatternName = pattern;
            m_Target = target;
            m_OldColor = oldColor;
            m_NewColor = newColor;
        }

        public void Apply(ToolBox toolbox)
        {
            toolbox.UpdatePatternTileColor(m_PatternName, m_Target, m_NewColor);
        }

        public void Undo(ToolBox toolbox)
        {
            toolbox.UpdatePatternTileColor(m_PatternName, m_Target, m_OldColor);
        }
    }

    public class StampBrushAction : IUndoableChange
    {
        private string m_PatternName;
        private PatternBlock[] m_Old;
        private PatternBlock[] m_Changed;

        public StampBrushAction(string pattern, PatternBlock[] old, PatternBlock[] changed)
        {
            m_PatternName = pattern;
            m_Old = old;
            m_Changed = changed;
        }

        public void Apply(ToolBox toolbox)
        {
            toolbox.UpdatePatternData(m_PatternName, m_Changed);
        }

        public void Undo(ToolBox toolbox)
        {
            toolbox.UpdatePatternData(m_PatternName, m_Old);
        }
    }

    public enum EPatternEditorTool
    {
        Stamp,
        Paint
    }

    public class PatternEditor : ITool
    {
        private Svarog m_Svarog;
        private Pattern m_Pattern;
        private Vector2 m_LastPaintXY;

        bool m_Grid = true;
        float m_Scale = 2;
        private bool m_Open = true;
        private EPatternEditorTool m_Tool = EPatternEditorTool.Stamp;

        public PatternEditor(Svarog svarog, string name) 
        {
            m_Svarog = svarog;
            Name = name;

            m_Pattern = m_Svarog.ToolBox.GetPattern(Name);
        }

        public string Name { get; set; }
        private Dictionary<string, (int, int)> TextureSizeCache = new();

        private (int, int) GetTextureSize(string name)
        {
            if (TextureSizeCache.ContainsKey(name))
            {
                return TextureSizeCache[name];
            }
            else
            {
                var data = m_Svarog.ToolBox.FileData[name];
                TextureSizeCache[name] = (data.Width, data.Height);
                return TextureSizeCache[name];
            }
        }

        public void Render(IWindow window)
        {
            /*
            var halfSize = new Vector2(m_Pattern.Width, m_Pattern.Height) * m_Pattern.GridSize / 2;
            ImGui.SetNextWindowSize(new Vector2(300, 300), ImGuiCond.FirstUseEver);

            if (ImGui.Begin($"{Name} ({m_Pattern.Width}x{m_Pattern.Height} @ {m_Pattern.GridSize})", ref m_Open, ImGuiWindowFlags.NoScrollbar))
            {
                var windowSize = ImGui.GetWindowSize();
                var grid = m_Grid ? "x" : " ";
                if (ImGui.Button($"Grid [{grid}]##GridOn")) { m_Grid = !m_Grid; }
                ImGui.SameLine();
                if (ImGui.Button("1x")) { m_Scale = 1; }
                ImGui.SameLine();
                if (ImGui.Button("2x")) { m_Scale = 2; }
                ImGui.SameLine();
                var stampName = m_Tool == EPatternEditorTool.Stamp ? "[Stamp]" : " Stamp ";
                if (ImGui.Button($"{stampName}##UseStamp")) { m_Tool = EPatternEditorTool.Stamp; }
                ImGui.SameLine();
                var paintName = m_Tool == EPatternEditorTool.Paint ? "[Paint]" : " Paint ";
                if (ImGui.Button($"{paintName}##UsePaint")) { m_Tool = EPatternEditorTool.Paint; }

                var windowPos = ImGui.GetWindowPos();
                var center = windowPos + windowSize / 2;
                var drawlist = ImGui.GetWindowDrawList();
                
                foreach (var block in m_Pattern.Data)
                {
                    var target = new Vector2(block.TargetId % m_Pattern.Width, block.TargetId / m_Pattern.Width);
                    var (w, h) = GetTextureSize(block.Source);
                    var source = new Vector2(block.SourceId % w, block.SourceId / w);
                    ms_Svarog.ToolBox.ImGuiDraw(block.Source, source, 
                        windowSize / 2 + target * m_Pattern.GridSize * m_Scale - halfSize * m_Scale, m_Scale, block.Color);
                }

                var mouse = ImGui.GetMousePos();

                var dxy = (mouse - center + halfSize * m_Scale) / (m_Pattern.GridSize * m_Scale);
                var dx = MathF.Round(dxy.X - 0.5f);
                var dy = MathF.Round(dxy.Y - 0.5f);

                dxy.X = dx;
                dxy.Y = dy;

                if (m_Tool == EPatternEditorTool.Stamp)
                {
                    if (mouse.Y - windowPos.Y > 55)
                    {
                        ms_Svarog.ToolBox.CurrentBrush?.ImGuiDraw(ms_Svarog.ToolBox,
                            windowSize / 2 + dxy * m_Pattern.GridSize * m_Scale - halfSize * m_Scale, m_Scale);
                    }
                }

                if (m_Grid)
                {
                    for (int i = 0; i <= m_Pattern.Width; i++)
                    {
                        drawlist.AddLine(
                            new System.Numerics.Vector2(center.X + i * m_Pattern.GridSize * m_Scale, center.Y) - halfSize * m_Scale,
                            new System.Numerics.Vector2(center.X + i * m_Pattern.GridSize * m_Scale, center.Y + m_Pattern.Height * m_Pattern.GridSize * m_Scale) - halfSize * m_Scale,
                            ImGui.GetColorU32(ImGuiCol.PlotLines));
                    }

                    for (int i = 0; i <= m_Pattern.Height; i++)
                    {
                        drawlist.AddLine(
                            new System.Numerics.Vector2(center.X, center.Y + i * m_Pattern.GridSize * m_Scale) - halfSize * m_Scale,
                            new System.Numerics.Vector2(center.X + m_Pattern.Width * m_Pattern.GridSize * m_Scale, center.Y + i * m_Pattern.GridSize * m_Scale) - halfSize * m_Scale,
                            ImGui.GetColorU32(ImGuiCol.PlotLines));
                    }
                }


                if (ImGui.IsWindowHovered())
                {
                    if (window.GetMouse().IsJustPressed(Mouse.Button.Left))
                    {
                        if (m_Tool == EPatternEditorTool.Stamp && ms_Svarog.ToolBox.CurrentBrush.HasValue)
                        {
                            var brush = ms_Svarog.ToolBox.CurrentBrush.Value;
                            var oldBlocks = m_Pattern.Data.ToArray();
                            foreach (var posInTexture in brush.Blocks)
                            {
                                var data = ms_Svarog.ToolBox.FileData[brush.Image];
                                var id = (int)(data.Width * posInTexture.Y + posInTexture.X);

                                var targetXY = posInTexture - brush.Min + dxy;
                                var target = (int)(targetXY.Y * m_Pattern.Width + targetXY.X);
                                if (target >= 0 && target < m_Pattern.Width * m_Pattern.Height)
                                {
                                    var pb = new PatternBlock(target, brush.Image, id);
                                    m_Pattern.Data.RemoveAll(b => b.TargetId == target);
                                    m_Pattern.Data.Add(pb);
                                }
                            }

                            var newBlocks = m_Pattern.Data.ToArray();
                            ms_Svarog.ToolBox.Apply(new StampBrushAction(m_Pattern.Name, oldBlocks, m_Pattern.Data.ToArray()));
                        }
                    }

                    if (window.GetMouse().IsDown(Mouse.Button.Left))
                    {
                        if (m_Tool == EPatternEditorTool.Paint)
                        {
                            var targetXY = dxy;
                            if (targetXY != m_LastPaintXY)
                            {
                                m_LastPaintXY = targetXY;
                                var target = (int)(targetXY.Y * m_Pattern.Width + targetXY.X);
                                var affected = m_Pattern.Data.Where(b => b.TargetId == target);
                                if (affected.Count() == 1)
                                {
                                    ms_Svarog.ToolBox.Apply(new PaintBrushAction(m_Pattern.Name, target, affected.First().Color, ms_Svarog.ToolBox.CurrentPaint));
                                }
                            }
                        }
                    }
                }
                else
                {
                    m_LastPaintXY = new Vector2(1000, 1000);
                }
                ImGui.End();
            }

            if (!m_Open)
            {
                ms_Svarog.ToolBox.ShouldClose(this);
                return;
            }

            if (m_Tool == EPatternEditorTool.Paint)
            {
                ImGui.SetNextWindowSize(new Vector2(400, 400));
                if (ImGui.Begin("PaintPicker", ImGuiWindowFlags.NoCollapse | ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoDecoration))
                {
                    ImGui.ColorPicker3("PaintPickerWheel", ref ms_Svarog.ToolBox.CurrentPaint, ImGuiColorEditFlags.PickerHueWheel);
                }
            }

            */
        }
    }
}
