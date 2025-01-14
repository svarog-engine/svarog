namespace svarog
{
    public interface IGameContext
    {
        IGameEvent? Interpret(IInput input);
    }
}
