using svagui.abstraction;
using svagui.extensions;
using svagui.extensions.instructions;
using svagui.platform;

using svarog.src.render;
using svarog.src.windowing;

using System;
using System.Drawing;
using System.Drawing.Printing;
using System.Reflection.Emit;

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

    public readonly struct DebugPrintLastLabel : IInstruction
    {
        public void Execute<P>(P platform) where P : IGUIPlatform
        {
            if ((bool)platform.GetEnvironment().Data["window-content-hovered"])
            {
                var text = (string)platform.GetEnvironment().Data["last-label-text"];
                Console.WriteLine(text);
            }
        }
    }

    public class FileManager : ITool
    {
        private Svarog m_Svarog;

        string? m_Selected = null;

        public string Name { get; set; }
        private string m_RenameName = "";

        private Vector2 m_Position = new Vector2(350, 350);
        private Vector2 m_Size = new Vector2(800, 300);
        private Palette m_Palette = new();
        private bool m_Visible = true;

        public FileManager(Svarog svarog)
        {
            Name = "FileManager";
            m_Svarog = svarog;
            svarog.ToolBox.RefreshFiles();
        }

        public void Render(IWindow window)
        {
            if (m_Visible)
            {
                var gui = window.GetGUI();

                gui.Run(
                    new PushContext("draw-debug-rect"),
                        new PushPrimaryColor(new svagui.abstraction.Color(0, 0, 0, 0)),
                        new PushSecondaryColor(new svagui.abstraction.Color(255, 0, 0, 255)),
                        new PushThickness(2),
                            new DrawRectangle(),
                        new PopThickness(),
                        new PopSecondaryColor(),
                        new PopPrimaryColor(),
                    new PopContext(),

                    new PushContext("debug-print"),
                        new DebugPrintLastLabel(),
                    new PopContext(),

                    new PushPositionAndSize(m_Position, m_Size),
                    new PushWindow("File Manager", m_Palette)
                );
                gui.GetEnvironment().UpdateWindow(ref m_Position, ref m_Visible);
                gui.Run(
                    new ConsumeMouseScrollIntoInputDelta(10.0f),
                    new PushClipView("window-inside"),
                    new PopAndSetMouseInputActive(),
                    new PushLayoutDirection(ELayoutDirection.Vertical)
                );

                foreach (var file in m_Svarog.ToolBox.Files)
                {
                    gui.Run(new DrawLabel(file));
                    var rect = (Rect)gui.GetEnvironment().Data["last-label-rect"];
                    gui.Run(
                        new PushPositionAndSize(rect.Pos, rect.Size),
                        new CheckIfCurrentHovered(),
                        new PopAnswerAndRunContextIfTrue("draw-debug-rect"),
                        new CheckIfCurrentLeftClicked(),
                        new PopAnswerAndRunContextIfTrue("debug-print"),
                        new PopPositionAndSize()
                    );
                }

                gui.Run(
                    new EnableMouseInputActive(),
                    new PopLayoutDirection(),
                    new PopClipView(),
                    new UnsetMouseInputOffset()
                );
                gui.Run(new PopWindow());
            }
        }
    }
}


//GUI.SetNextWindowPosition(50, 50);
//GUI.SetNextWindowSize(500, 300);
//GUI.Window("File Manager");
//GUI.PushLayout(ELayoutDirection.Horizontal);
//for (int i = 0; i < 10; i++)
//    GUI.Text($"File {i}");
//GUI.PopLayout();
//GUI.End();
/*
ImGui.SetNextWindowSize(new System.Numerics.Vector2(500, 200), ImGuiCond.FirstUseEver);
ImGui.Window("File Manager");

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
                //ms_Svarog.ToolBox.PatternPreview = file;
            }
            ImGui.TreePop();
        }
    }

    ImGui.TreePop();
}

ImGui.End();
*/