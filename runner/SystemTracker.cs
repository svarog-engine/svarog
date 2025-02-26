namespace svarog.runner
{
    internal class SystemTracker
    {
        public string Name { get; set; } = "";

        public void Set(string name)
        {
            Name = name;
        }

        public void Reset()
        {
            Name = "X";
        }
    }
}