using SFML.Graphics;

using svarog.presentation;
using svarog.runner;

namespace svarog.utility
{
    internal class Randomness
    {
        public static readonly Randomness Instance = new Randomness();

        private static readonly string ALPHABET = "thequickbrownfoxjumpsoverthelazydog.,;[]()";
        private System.Random Internal = new();

        public bool Coin() => Internal.Next(100) >= 50;
        public int Range(int min, int max) => min + Internal.Next(max);
        public string From(string ts) => ts[Range(0, ts.Length)].ToString();
        public T From<T>(T[] ts) => ts[Range(0, ts.Length)];
        public T From<T>(List<T> ts) => ts[Range(0, ts.Count)];
        public string Char() => From(ALPHABET);
        public void Shuffle<T>(IList<T> ts)
        {
            var count = ts.Count;
            var last = count - 1;
            for (var i = 0; i < last; ++i)
            {
                var r = Range(i, count);
                var tmp = ts[i];
                ts[i] = ts[r];
                ts[r] = tmp;
            }
        }

    }
}
