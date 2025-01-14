namespace svarog.input
{
    public class InputParser
    {
        private readonly Queue<IInput> m_Inputs = new();
        private readonly Queue<IInput> m_UnconsumedInputs = new();

        private readonly Stack<IGameContext> m_Contexts = new();
        private readonly Queue<IGameEvent> m_Events = new();

        public Stack<IGameContext> Contexts => m_Contexts;

        public void Enqueue(IInput input) 
        {
            m_Inputs.Enqueue(input);
        }

        public void ProduceGameEvents()
        {
            m_UnconsumedInputs.Clear();

            while (m_Inputs.Count > 0)
            {
                var input = m_Inputs.Dequeue();
                bool consumed = false;
                foreach (var context in m_Contexts)
                {
                    var ev = context.Interpret(input);
                    if (ev != null)
                    {
                        m_Events.Enqueue(ev);
                        consumed = true;
                        break;
                    }
                }

                if (!consumed)
                {
                    m_UnconsumedInputs.Enqueue(input);
                }
            }

            foreach (var input in m_UnconsumedInputs)
            {
                m_Inputs.Enqueue(input);
            }
        }

    }
}
