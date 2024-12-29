using ImGuiNET;
using svarog.src.windowing;

namespace svarog.src.tools
{
    public enum EFileType
    {
        Spritesheet6x6,
        Spritesheet8x8,
        Spritesheet10x10,
        Spritesheet12x12,
        Spritesheet16x16,
        Image,
        Pattern,
    }

    public static class EFileTypeExt
    {
        public static int GridSize(this EFileType type)
        {
            switch (type)
            {
                case EFileType.Spritesheet6x6: return 6;
                case EFileType.Spritesheet8x8: return 8;
                case EFileType.Spritesheet10x10: return 10;
                case EFileType.Spritesheet12x12: return 12;
                case EFileType.Spritesheet16x16: return 16;
                case EFileType.Pattern: return 0;
                case EFileType.Image: default: return 0;
            }
        }

        public static string Stringify(this EFileType type)
        {
            switch (type)
            {
                case EFileType.Spritesheet6x6: return "Spritesheet (6x6)";
                case EFileType.Spritesheet8x8: return "Spritesheet (8x8)";
                case EFileType.Spritesheet10x10: return "Spritesheet (10x10)";
                case EFileType.Spritesheet12x12: return "Spritesheet (12x12)";
                case EFileType.Spritesheet16x16: return "Spritesheet (16x16)";
                case EFileType.Image: return "Image";
                case EFileType.Pattern: return "Pattern";
                default: return "Unknown";
            }
        }
    }

    public struct FileData
    {
        public string Name { get; set; }
        public string Path { get; set; }
        public EFileType Type { get; set; }
        public int Width { get; set; }
        public int Height { get; set; }
    }

    public class FileManager : ITool
    {
        private Svarog m_Svarog;

        string? m_Selected = null;

        public string Name { get; set; }
        private string m_RenameName = "";

        public FileManager(Svarog svarog)
        {
            Name = "FileManager";
            m_Svarog = svarog;
            svarog.ToolBox.RefreshFiles();
        }

        public void Render(IWindow window)
        {
            var keyboard = window.GetKeyboard();
            var toolbox = m_Svarog.ToolBox;

            ImGui.SetNextWindowSize(new System.Numerics.Vector2(500, 200), ImGuiCond.FirstUseEver);
            ImGui.Begin("File Manager");

            if (ImGui.TreeNodeEx("Files", ImGuiTreeNodeFlags.DefaultOpen))
            {
                foreach (var file in toolbox.Files)
                {
                    var flags = ImGuiTreeNodeFlags.Bullet;
                    if (m_Selected == file)
                    {
                        flags |= ImGuiTreeNodeFlags.Selected;
                    }

                    if (ImGui.TreeNodeEx(file, flags))
                    {
                        if (ImGui.IsItemClicked())
                        {
                            m_Selected = file;

                            if (file.EndsWith(".png"))
                            {
                                window.GetCore().ToolBox.OpenImageSampler(toolbox.FileData[file]);
                            }
                            else if (file.EndsWith(".pat"))
                            {
                                window.GetCore().ToolBox.OpenPatternEditor(file);
                            }
                        }

                        if (ImGui.IsItemHovered() && file.EndsWith(".pat"))
                        {
                            //m_Svarog.ToolBox.PatternPreview = file;
                        }
                        ImGui.TreePop();
                    }
                }

                ImGui.TreePop();
            }
           
            ImGui.End();
        }
    }
}
