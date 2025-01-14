namespace svarog.input.devices
{
    public readonly record struct GamepadInput(int Scancode, float Value) : IInput { }
}
