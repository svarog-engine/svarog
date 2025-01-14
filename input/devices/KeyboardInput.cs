namespace svarog.input.devices
{
    public readonly record struct KeyboardInput(int Scancode, int Value) : IInput
    { }
}
