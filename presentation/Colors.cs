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
        public Color Random
        {
            get
            {
                var rgb = RandomColor.GetColor(ColorScheme.Random, Luminosity.Bright);
                return new Color(rgb.R, rgb.B, rgb.G, rgb.A);
            }
        }
    }
}
