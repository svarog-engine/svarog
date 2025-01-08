using SFML.Graphics;
using SFML.System;
using SFML.Window;

namespace svarog.src.tools
{
    //public struct GUIState
    //{
    //    public static Vector2f DefaultWindowPosition = new Vector2f(100, 100);
    //    public static Vector2f DefaultWindowSize = new Vector2f(300, 300);

    //    public Vector2f NextWindowPosition;
    //    public Vector2f NextWindowSize;

    //    public Vector2f LayoutPosition;
    //    public Vector2f LayoutSize;

    //    public Vector2f LastElementPosition;
    //    public Vector2f LastElementSize;
    //}

    //public struct GUIPalette
    //{
    //    public Color WindowColor = new Color(30, 35, 36, 220);
    //    public Color WindowTitlebarColor = new Color(46, 46, 46, 220);
    //    public Color WindowOutlineColor = new Color(200, 200, 200, 220);

    //    public GUIPalette()
    //    {}
    //}

    //public enum ELayoutDirection
    //{
    //    Horizontal,
    //    Vertical,
    //}

    //public class Subdivision
    //{}

    //public class SubdivAbsoluteSize(float size) : Subdivision 
    //{
    //    public float Size => size;
    //}

    //public class SubdivStretch(float ratio) : Subdivision 
    //{
    //    public float Ratio => ratio;
    //}

    //public class GUI
    //{
    //    static Svarog ms_Svarog;
         
    //    public static GUIState State = new();
    //    public static GUIPalette Palette = new();

    //    private static CircleShape ms_Circle = new();
    //    private static RectangleShape ms_Rect = new();
    //    private static Stack<ELayoutDirection> ms_LayoutStack = new();

    //    private static Vertex[] ms_Line = new Vertex[2];
    //    private static Font? ms_Font;
    //    private static Text ms_Text = new();
    //    private static ELayoutDirection ms_Direction = ELayoutDirection.Vertical;
        
    //    private static Stack<Subdivision[]> ms_Subdivisions = new();
    //    private static List<float> ms_SubdivPositionStarts = new();
    //    private static Stack<int> ms_SubdivisionIndices = new();

    //    public static void Init(Svarog svarog)
    //    {
    //        ms_Svarog = svarog;
    //        ms_Font = new("mont.ttf");
    //        ms_LayoutStack.Push(ELayoutDirection.Vertical);
    //    }

    //    public static void SetNextWindowSize(float x, float y)
    //    {
    //        State.NextWindowSize.X = x;
    //        State.NextWindowSize.Y = y;
    //    }

    //    public static void SetNextWindowPosition(float x, float y)
    //    {
    //        State.NextWindowPosition.X = x;
    //        State.NextWindowPosition.Y = y;
    //    }

    //    public static void PushLayout(ELayoutDirection layout)
    //    {
    //        ms_LayoutStack.Push(layout);
    //    }

    //    public static void PopLayout()
    //    {
    //        ms_LayoutStack.Pop();
    //    }

    //    public static ELayoutDirection GetLayout()
    //    {
    //        if (ms_LayoutStack.TryPeek(out var layout))
    //        {
    //            return layout;
    //        }

    //        return ELayoutDirection.Vertical;
    //    }

    //    public static void Window(string name)
    //    {
    //        // draw window rect
    //        State.LayoutPosition = State.NextWindowPosition;
    //        ms_Rect.Size = State.NextWindowSize;
    //        ms_Rect.FillColor = Palette.WindowColor;
    //        ms_Rect.OutlineColor = Palette.WindowOutlineColor;
    //        ms_Rect.OutlineThickness = 0;
    //        ms_Rect.Position = State.NextWindowPosition;
    //        ms_Svarog.MainWindow.Window?.Draw(ms_Rect);

    //        // draw titlebar
    //        ms_Rect.Size = new Vector2f(State.NextWindowSize.X, 20);
    //        ms_Rect.FillColor = Palette.WindowTitlebarColor;
    //        ms_Rect.OutlineThickness = 0;
    //        ms_Svarog.MainWindow.Window?.Draw(ms_Rect);

    //        State.LayoutPosition = State.NextWindowPosition;
    //        State.LayoutSize = new Vector2f(State.NextWindowSize.X, 18);

    //        PushLayout(ELayoutDirection.Vertical);
    //        {
    //            Space(2);
    //            PushLayout(ELayoutDirection.Horizontal);
    //            {
    //                PushSubdivide(new SubdivAbsoluteSize(6), new SubdivStretch(1), new SubdivAbsoluteSize(20));
    //                /* space */ {
    //                    SubdivNext();
    //                }
    //                /* title */ {
    //                    var rect = SubdivSize();
    //                    bool hovered = IsLastElementHovered(rect);
    //                    Text(name, SFML.Graphics.Text.Styles.Bold, hovered ? Color.White : null);

    //                    State.LastElementPosition = rect.Position;
    //                    State.LastElementSize = rect.Size;
    //                    SubdivNext();
    //                }
    //                /* exit button */ {
    //                    Bullet(5.5f);
    //                    if (IsLastElementHovered())
    //                    {
    //                        Bullet(5.5f, Color.White);
    //                    }

    //                    if (IsLastElementClicked())
    //                    {
    //                        ms_Svarog.MainWindow.ToolsVisible = false;
    //                    }

    //                    SubdivNext();
    //                }
    //                PopSubdivide();
    //            }
    //            PopLayout();
    //        }
    //        PopLayout();

    //        State.LastElementPosition = State.LayoutPosition;
    //        State.LastElementSize = State.LayoutSize;

    //        // internal
    //        State.LayoutPosition = State.NextWindowPosition + new Vector2f(6, 22);
    //        State.LayoutSize = State.NextWindowSize - new Vector2f(12, 4);
    //    }

    //    public static bool IsLastElementClicked(FloatRect? box = null)
    //    {
    //        if (!box.HasValue)
    //        {
    //            box = new FloatRect(State.LastElementPosition, State.LastElementSize);
    //        }

    //        if (ms_Svarog.MainWindow != null)
    //        {
    //            var mouse = ms_Svarog.MainWindow.GetMouse();
    //            var (x, y) = mouse.Position;
    //            return box.Value.Contains(new Vector2f(x, y)) && mouse.IsJustReleased(Mouse.Button.Left);
    //        }

    //        return false;
    //    }

    //    public static bool IsLastElementHovered(FloatRect? box = null)
    //    {
    //        if (!box.HasValue)
    //        {
    //            box = new FloatRect(State.LastElementPosition, State.LastElementSize);
    //        }

    //        if (ms_Svarog.MainWindow != null)
    //        {
    //            var mouse = ms_Svarog.MainWindow.GetMouse();
    //            return box.Value.Contains(new Vector2f(mouse.Position.Item1, mouse.Position.Item2));
    //        }

    //        return false;
    //    }

    //    public static void PushSubdivide(params Subdivision[] subdiv)
    //    {
    //        ms_Subdivisions.Push(subdiv);
    //        ms_SubdivisionIndices.Push(0);

    //        ms_SubdivPositionStarts.Clear();

    //        var size = GetLayout() == ELayoutDirection.Horizontal ? State.LayoutSize.X : State.LayoutSize.Y;
    //        var parts = 0.0f;

    //        foreach (var div in subdiv)
    //        {
    //            if (div is SubdivAbsoluteSize abs)
    //            {
    //                size -= abs.Size;
    //            }
    //            else if (div is SubdivStretch str)
    //            {
    //                parts += str.Ratio;
    //            }
    //        }

    //        var start = GetLayout() == ELayoutDirection.Horizontal ? State.LayoutPosition.X : State.LayoutPosition.Y;
    //        foreach (var div in subdiv)
    //        {
    //            if (div is SubdivAbsoluteSize abs)
    //            {
    //                start += abs.Size;
    //                ms_SubdivPositionStarts.Add(start);
    //            }
    //            else if (div is SubdivStretch str)
    //            {
    //                start += size / parts * str.Ratio;
    //                ms_SubdivPositionStarts.Add(start);
    //            }
    //        }
    //    }

    //    public static void PopSubdivide()
    //    {
    //        if (ms_Subdivisions.Count > 0)
    //        {
    //            ms_Subdivisions.Pop();
    //            ms_SubdivisionIndices.Pop();
    //            ms_SubdivPositionStarts.Clear();
    //        }
    //        else
    //        {
    //            Console.WriteLine("PopSubdivide called without divisions!");
    //        }
    //    }

    //    public static int SubdivIndex()
    //    {
    //        if (ms_SubdivisionIndices.TryPeek(out int index))
    //        {
    //            return index;
    //        }
    //        else
    //        {
    //            Console.WriteLine("SubdivIndex called without divisions!");
    //            return 0;
    //        }
    //    }

    //    public static void SubdivReset()
    //    {
    //        if (ms_SubdivisionIndices.TryPeek(out int index))
    //        {
    //            ms_SubdivisionIndices.Push(0);
    //        }
    //        else
    //        {
    //            Console.WriteLine("SubdivReset called without divisions!");
    //        }
    //    }

    //    public static FloatRect SubdivSize()
    //    {
    //        var pos = State.LayoutPosition;
    //        var size = State.LayoutSize;

    //        if (ms_SubdivisionIndices.TryPeek(out int index))
    //        {
    //            if (GetLayout() == ELayoutDirection.Horizontal)
    //            {
    //                pos.X = ms_SubdivPositionStarts[index - 1];
    //                size.X = ms_SubdivPositionStarts[index] - ms_SubdivPositionStarts[index - 1];
    //            }
    //            else
    //            {
    //                pos.Y = ms_SubdivPositionStarts[index - 1];
    //                size.Y = ms_SubdivPositionStarts[index] - ms_SubdivPositionStarts[index - 1];
    //                //size.Y = State.LayoutPosition.Y;
    //            }
    //        }

    //        return new FloatRect(pos, size);
    //    }

    //    public static void SubdivNext()
    //    {
    //        var oldPos = State.LayoutPosition;
    //        State.LastElementPosition = State.LayoutPosition;
    //        State.LastElementSize = State.LayoutSize;

    //        if (ms_SubdivisionIndices.TryPop(out int index))
    //        {
    //            int nextIndex = index + 1;

    //            if (GetLayout() == ELayoutDirection.Horizontal)
    //            {
    //                State.LayoutPosition.X = ms_SubdivPositionStarts[index];
    //                State.LastElementSize.X = State.LayoutPosition.X - oldPos.X;
    //            } 
    //            else
    //            {
    //                State.LayoutPosition.Y = ms_SubdivPositionStarts[index];
    //                State.LastElementSize.Y = State.LayoutPosition.Y - oldPos.Y;
    //            }

    //            ms_SubdivisionIndices.Push(nextIndex);
    //        }
    //    }

    //    public static void Space(int space)
    //    {
    //        if (GetLayout() == ELayoutDirection.Vertical)
    //        {
    //            State.LayoutPosition += new Vector2f(0, space);
    //        }
    //        else
    //        {
    //            State.LayoutPosition += new Vector2f(space, 0);
    //        }
    //    }

    //    public static void Bullet(float size, Color? color = null)
    //    {
    //        ms_Circle.Position = State.LayoutPosition + new Vector2f(size / 2, size / 2);
    //        ms_Circle.Radius = size;
    //        ms_Circle.FillColor = color.HasValue ? color.Value : Palette.WindowOutlineColor;
    //        ms_Svarog.MainWindow.Window?.Draw(ms_Circle);

    //        State.LastElementPosition = State.LayoutPosition + new Vector2f(size / 2, size / 2);
    //        State.LastElementSize = new Vector2f(size * 2, size * 2);
    //    }

    //    public static void Text(string text, Text.Styles style = SFML.Graphics.Text.Styles.Regular, Color? color = null, uint size = 12)
    //    {
    //        ms_Text.Font = ms_Font; 
    //        ms_Text.Style = style;
    //        ms_Text.DisplayedString = text;
    //        ms_Text.CharacterSize = size;
    //        ms_Text.FillColor = color.HasValue ? color.Value : Palette.WindowOutlineColor;
    //        ms_Text.Position = State.LayoutPosition;
    //        ms_Svarog.MainWindow.Window?.Draw(ms_Text);

    //        ELayoutDirection layout = ELayoutDirection.Vertical;
    //        ms_LayoutStack.TryPeek(out layout);

    //        var bounds = ms_Text.GetLocalBounds();

    //        State.LastElementPosition = State.LayoutPosition;
    //        State.LastElementSize = new Vector2f(bounds.Width, 20);

    //        if (layout == ELayoutDirection.Vertical) 
    //        {
    //            State.LayoutPosition += new Vector2f(0, bounds.Height + 6);
    //        } 
    //        else
    //        {
    //            State.LayoutPosition += new Vector2f(bounds.Width + 6, 0);
    //        }
    //    }

    //    public static void DebugRect(FloatRect rect)
    //    {
    //        ms_Rect.Position = rect.Position;
    //        ms_Rect.Size = rect.Size;
    //        ms_Rect.FillColor = Color.Transparent;
    //        ms_Rect.OutlineColor = Color.Yellow;
    //        ms_Rect.OutlineThickness = 1;
    //        ms_Svarog.MainWindow.Window?.Draw(ms_Rect);
    //    }

    //    public static void LastElementDebugRect()
    //    {
    //        ms_Rect.Position = State.LastElementPosition;
    //        ms_Rect.Size = State.LastElementSize;
    //        ms_Rect.FillColor = Color.Transparent;
    //        ms_Rect.OutlineColor = Color.Red;
    //        ms_Rect.OutlineThickness = 1;
    //        ms_Svarog.MainWindow.Window?.Draw(ms_Rect);
    //    }

    //    public static void End() 
    //    {
    //        State.NextWindowPosition = GUIState.DefaultWindowPosition;
    //        State.NextWindowSize = GUIState.DefaultWindowSize;
    //    }

    //}


}
