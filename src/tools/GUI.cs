using SFML.Graphics;
using SFML.System;
using SFML.Window;

using System.Xml.Linq;

namespace svarog.src.tools
{
    public struct GUIState
    {
        public static Vector2f DefaultWindowPosition = new Vector2f(100, 100);
        public static Vector2f DefaultWindowSize = new Vector2f(300, 300);

        public Vector2f NextWindowPosition;
        public Vector2f NextWindowSize;

        public Vector2f LayoutPosition;
        public Vector2f LayoutSize;
    }

    public struct GUIPalette
    {
        public Color WindowColor = new Color(77, 97, 96, 120);
        public Color WindowOutlineColor = new Color(200, 200, 200, 120);

        public GUIPalette()
        {}
    }

    public enum ELayoutDirection
    {
        Horizontal,
        Vertical,
    }

    public class GUI
    {
        static Svarog ms_Svarog;
        
        public static GUIState State = new();
        public static GUIPalette Palette = new();

        private static RectangleShape ms_Rect = new();
        private static Vertex[] ms_Line = new Vertex[2];
        private static Font ms_Font;
        private static Text ms_Text = new();
        private static ELayoutDirection ms_Direction = ELayoutDirection.Vertical;    
        public static void Init(Svarog svarog)
        {
            ms_Svarog = svarog;
            ms_Font = new("mont.ttf");
        }

        public static void SetNextWindowSize(float x, float y)
        {
            State.NextWindowSize.X = x;
            State.NextWindowSize.Y = y;
        }

        public static void SetNextWindowPosition(float x, float y)
        {
            State.NextWindowPosition.X = x;
            State.NextWindowPosition.Y = y;
        }

        public static void Begin(string name)
        {
            // draw rect
            State.LayoutPosition = State.NextWindowPosition;
            ms_Rect.Size = State.NextWindowSize;
            ms_Rect.FillColor = Palette.WindowColor;
            ms_Rect.OutlineColor = Palette.WindowOutlineColor;
            ms_Rect.OutlineThickness = 1;
            ms_Rect.Position = State.NextWindowPosition;
            ms_Svarog.MainWindow.Window?.Draw(ms_Rect);

            // draw title line
            ms_Line[0].Position = State.NextWindowPosition + new Vector2f(0, 20);
            ms_Line[0].Color = Palette.WindowOutlineColor;
            ms_Line[1].Position = State.NextWindowPosition + new Vector2f(State.NextWindowSize.X, 20);
            ms_Line[1].Color = Palette.WindowOutlineColor;
            ms_Svarog.MainWindow.Window?.Draw(ms_Line, PrimitiveType.Lines);

            // draw title
            ms_Text.Font = ms_Font;
            ms_Text.DisplayedString = name;
            ms_Text.CharacterSize = 12;
            ms_Text.FillColor = Palette.WindowOutlineColor;
            ms_Text.Position = State.NextWindowPosition + new Vector2f(6, 2);
            ms_Svarog.MainWindow.Window?.Draw(ms_Text);

            State.LayoutPosition = State.NextWindowPosition + new Vector2f(2, 22);
            State.LayoutSize = State.NextWindowSize - new Vector2f(4, 4);
        }

        public static void Text(string text)
        {
            ms_Text.Font = ms_Font;
            ms_Text.DisplayedString = text;
            ms_Text.CharacterSize = 12;
            ms_Text.FillColor = Palette.WindowOutlineColor;
            ms_Text.Position = State.LayoutPosition;
            ms_Svarog.MainWindow.Window?.Draw(ms_Text);

            State.LayoutPosition += new Vector2f(0, 14);
        }

        public static void End() 
        {
            State.NextWindowPosition = GUIState.DefaultWindowPosition;
            State.NextWindowSize = GUIState.DefaultWindowSize;
        }

    }
}
