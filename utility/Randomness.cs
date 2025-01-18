using SFML.Graphics;

using svarog.presentation;

namespace svarog.utility
{
    internal class Randomness
    {
        private Colors Colors = new();
        private System.Random Internal = new();

        public int Get(int min, int max) => min + Internal.Next(max);
        public string Get(string ts) => ts[Get(0, ts.Length)].ToString();
        public T Get<T>(T[] ts) => ts[Get(0, ts.Length)];
        public T Get<T>(List<T> ts) => ts[Get(0, ts.Count)];
        public Color Color() => Colors.Random;
    }
}
