using SFML.Graphics;

namespace svarog
{
    public record struct Glyph(string Presentation, Color Foreground)
    {
        //private RandomColor backgroundColor = new RandomColor();

        //public Color Background => backgroundColor.Background;

        private Color m_BackgroundColor = new RandomColor().Background;
        public Color Background => m_BackgroundColor;
    }

    public class RandomColor
    {
        static Color[] colors = {Color.Green, Color.Black, Color.Blue, Color.Red};
        static Random random = new Random();
        public Color Background { get => colors[random.Next(0, colors.Length)]; }
    }
}
