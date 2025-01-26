using SFML.Graphics;

using svarog.presentation;
using svarog.runner;

namespace svarog.utility
{
    internal class Randomness
    {
        private static readonly string ALPHABET = "thequickbrownfoxjumpsoverthelazydog.,;[]()";
        private System.Random Internal = new();
        
        public int Range(int min, int max) => min + Internal.Next(max);
        public string From(string ts) => ts[Range(0, ts.Length)].ToString();
        public T From<T>(T[] ts) => ts[Range(0, ts.Length)];
        public T From<T>(List<T> ts) => ts[Range(0, ts.Count)];
        public string Char() => From(ALPHABET);
    }
}
