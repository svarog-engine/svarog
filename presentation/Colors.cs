using RandomColorGenerator;

using SFML.Graphics;

namespace svarog.presentation
{
    internal class Colors
    {
        public Color Hex(string hex) => hex.ToColor();

        public Color Red = new(179, 33, 52);
        public Color LightRed = new(236, 100, 75);
        public Color DarkRed = new(139, 0, 0);

        public Color Green = new(8, 144, 0);
        public Color LightGreen = new(31, 198, 0);
        public Color DarkGreen = new(10, 93, 0);

        public Color Blue = new(82, 138, 174);
        public Color LightBlue = new(167, 231, 254);
        public Color DarkBlue = new(46, 89, 132);

        public Color Cyan = new(67, 204, 190);
        public Color LightCyan = new(107, 240, 221);
        public Color DarkCyan = new(34, 175, 167);

        public Color Magenta = new(136, 0, 139);
        public Color LightMagenta = new(204, 53, 146);
        public Color DarkMagenta = new(70, 45, 112);

        public Color Yellow = new(254, 208, 108);
        public Color LightYellow = new(255, 228, 138);
        public Color DarkYellow = new(253, 177, 63);

        public Color Brown = new(124, 73, 48);
        public Color LightBrown = new(198, 143, 112);
        public Color DarkBrown = new(87, 55, 45);

        public Color Gray = new(83, 83, 83);
        public Color LightGray = new(166, 169, 164);
        public Color DarkGray = new(48, 45, 46);

        public Color Black = Color.Black;
        public Color White = Color.White;
        public Color Transparent = Color.Transparent;

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

    public static class ColorExtensions
    {
        public static Color ToColor(this string hex)
        {
            return HexToColor(hex);
        }
        public static Color HexToColor(string hexString)
        {
            if (hexString.IndexOf('#') != -1) 
                hexString = hexString.Replace("#", ""); 
            
            byte r, g, b = 0; 
            r = byte.Parse(hexString.Substring(0, 2), System.Globalization.NumberStyles.HexNumber); 
            g = byte.Parse(hexString.Substring(2, 2), System.Globalization.NumberStyles.HexNumber);
            b = byte.Parse(hexString.Substring(4, 2), System.Globalization.NumberStyles.HexNumber); 
            return new Color(r, g, b); 
        }
    }
}
