namespace svarog.input.devices
{
    public readonly record struct MouseInput(int Button, int Value, int X, int Y) : IInput
    { }
}
