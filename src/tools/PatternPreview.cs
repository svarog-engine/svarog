using svarog.src.windowing;
using System.Numerics;

namespace svarog.src.tools
{
    public class PatternPreview : ITool
    {
        public string Name { get; set; }
        private Svarog m_Svarog;

        public PatternPreview(Svarog svarog)
        {
            Name = "Preview";
            m_Svarog = svarog;
        }

        public void Render(IWindow window)
        {
            if (m_Svarog.ToolBox.CurrentBrush == null)
                return;

            var brush = m_Svarog.ToolBox.CurrentBrush.Value;
            var data = m_Svarog.ToolBox.FileData[brush.Image];
            var size = new Vector2(50, 50);

            //ImGui.SetNextWindowSize(2 * size + brush.Size * data.Type.GridSize() + brush.Size * data.Type.GridSize() * 2.0f, ImGuiCond.Always);
            //ImGui.Begin("Preview", ImGuiWindowFlags.NoResize);

            //var xy = ImGui.GetCursorPos();
            //brush.ImGuiDraw(ms_Svarog.ToolBox, xy, 1.0f);

            //xy.X += brush.Size.X * data.Type.GridSize() + 20;
            //ImGui.SetCursorPos(xy);
            //brush.ImGuiDraw(ms_Svarog.ToolBox, xy, 2.0f);
            //ImGui.End();
        }
    }
}
