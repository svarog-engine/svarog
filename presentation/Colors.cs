using RandomColorGenerator;

using SFML.Graphics;

namespace svarog.presentation
{
    internal class Colors
    {
        public Color Red = Color.Red;
        public Color Green = Color.Green;
        public Color Blue = Color.Blue;
        public Color Cyan = Color.Cyan;
        public Color Magenta = Color.Magenta;
        public Color Yellow = Color.Yellow;
        public Color Black = Color.Black;
        public Color White = Color.White;
        public Color Gray = new Color(128, 128, 128);

        public Color Random
        {
            get
            {
                var rgb = RandomColor.GetColor(ColorScheme.Random, Luminosity.Bright);
                return new Color(rgb.R, rgb.B, rgb.G, rgb.A);
            }
        }

        public Color Lerp(Color a, Color b, float t)
            => a.Lerp(b, t);
    }

    public static class LerpExtensions
    {
        public static float Lerp(this float a, float b, float t)
        {
            return a + (b - a) * t;
        }

        public static Color Lerp(this Color color, Color target, float t)
        {
            byte r = (byte)((float)color.R).Lerp(target.R, t);
            byte g = (byte)((float)color.G).Lerp(target.G, t);
            byte b = (byte)((float)color.B).Lerp(target.B, t);
            return new Color(r, g, b);
        }
    }
}
