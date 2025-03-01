using NLua;
using svarog.runner;

namespace svarog.input
{
    public enum EInputActionType
    {
        Press,
        Hold,
        Release,
        MouseMove,
    }

    public record struct InputAction(EInputActionType Action, string Input, float? Length, int X = 0, int Y = 0)
    {
        public InputAction(EInputActionType action, string input) : this(action, input, null) { }
        public InputAction(EInputActionType action, string input, float length) : this(action, input, length, 0, 0) { }
    }

    public record struct InputContext(Dictionary<string, List<InputAction>> Actions);
    public class InputManager
    {
        private Dictionary<string, InputContext> m_RegisteredContexts = [];
        private List<string> m_RegisteredActions = [];

        private Stack<string> m_ContextStack = new();

        private Dictionary<string, float> m_HeldLengths = [];

        private List<string> m_Triggered = [];
        public List<string> Triggered => m_Triggered;

        public int MouseX { get; set; } = 0;
        public int MouseY { get; set; } = 0;

        public InputManager()
        {
        }

        public void ReloadActions()
        {
            var svarog = Svarog.Instance;
            m_RegisteredActions.Clear();
            m_ContextStack.Clear();
            m_HeldLengths.Clear();
            m_RegisteredContexts.Clear();

            svarog.RunScript("Actions = {}");
            svarog.RunScriptFile("scripts\\Actions");

            if (svarog.Scripting["Actions"] is LuaTable table)
            {
                foreach (var okey in table.Keys)
                {
                    var contextKey = okey.ToString();

                    if (table[contextKey] is LuaTable context)
                    {
                        if (!m_RegisteredContexts.ContainsKey(contextKey))
                        {
                            m_RegisteredContexts[contextKey] = new InputContext([]);
                        }

                        foreach (var input in context.Keys)
                        {                            
                            if (context[input] is LuaTable actions)
                            {
                                var inputKey = input.ToString();
                                if (!m_RegisteredContexts[contextKey].Actions.ContainsKey(inputKey))
                                {
                                    m_RegisteredContexts[contextKey].Actions[inputKey] = new();
                                }

                                foreach (var oaction in actions.Values)
                                {
                                    var action = oaction as LuaTable;
                                    var act = action["action"] as string;
                                    var eact = act switch
                                    {
                                        "press" => EInputActionType.Press,
                                        "hold" => EInputActionType.Hold,
                                        "release" => EInputActionType.Release,
                                        "mousemove" => EInputActionType.MouseMove,
                                        _ => EInputActionType.Press,
                                    };

                                    var inp = action["input"] as string;
                                    var len = float.Parse(action["length"].ToString());

                                    m_RegisteredContexts[contextKey].Actions[inputKey].Add(new InputAction(eact, inp, len));
                                }
                            }
                        }
                    }
                }
            }
        
            foreach (var contextKey in m_RegisteredContexts.Keys)
            {
                foreach (var action in m_RegisteredContexts[contextKey].Actions)
                {
                    var component = $"Action_{contextKey}_{action.Key}";
                    if (!m_RegisteredActions.Contains(component))
                    {
                        m_RegisteredActions.Add(component);
                        svarog.RunScript($"{component} = ECS.Component({{}})");
                        svarog.LogVerbose($"Generated input action component {component}");
                    }
                }
            }
        }

        public void Push(string context)
        {
            m_ContextStack.Push(context);
        }

        public void PopAll()
        {
            m_ContextStack.Clear();
        }

        public void Pop()
        {
            if (m_ContextStack.Count > 0)
            {
                m_ContextStack.Pop();
            }
        }

        public string Peek()
        {
            if (m_ContextStack.Count > 0)
            {
                return m_ContextStack.Peek();
            }
            else
            {
                return "Default";
            }
        }

        public void Clear()
        {
            m_Triggered.Clear();
        }

        public void Update()
        {
            foreach (var held in m_HeldLengths.Keys)
            {
                m_HeldLengths[held] += Svarog.Instance.DeltaTime;

                if (m_ContextStack.TryPeek(out var context))
                {
                    foreach (var (action, inputs) in m_RegisteredContexts[context].Actions)
                    {
                        bool foundActionTrigger = false;
                        foreach (var input in inputs)
                        {
                            if (input.Input == held && input.Action == EInputActionType.Hold)
                            {
                                if (m_HeldLengths[held] >= input.Length)
                                {
                                    foundActionTrigger = true;
                                    break;
                                }
                            }
                        }

                        if (foundActionTrigger)
                        {
                            m_Triggered.Add(action);
                            m_HeldLengths.Remove(held);
                            break;
                        }
                    }
                }
            }
        }

        public void Enqueue(InputAction inputAction)
        {
            if (m_ContextStack.TryPeek(out var context))
            {
                foreach (var (action, inputs) in m_RegisteredContexts[context].Actions)
                {
                    bool foundActionTrigger = false;
                    foreach (var input in inputs)
                    {
                        if (input.Input == inputAction.Input && input.Action == inputAction.Action)
                        {
                            if ((input.Action == EInputActionType.Press && !m_HeldLengths.ContainsKey(inputAction.Input))
                                || input.Action == EInputActionType.Release)
                            {
                                foundActionTrigger = true;
                                break;
                            }
                            else if (input.Action == EInputActionType.MouseMove)
                            {
                                MouseX = inputAction.X;
                                MouseY = inputAction.Y;

                                foundActionTrigger = true;
                                break;
                            }
                        }
                    }

                    if (foundActionTrigger)
                    {
                        m_Triggered.Add(action);
                        break;
                    }
                }
            }

            if (inputAction.Action == EInputActionType.Press)
            {
                if (!m_HeldLengths.ContainsKey(inputAction.Input))
                {
                    m_HeldLengths[inputAction.Input] = 0;
                }
            }
            else if (inputAction.Action == EInputActionType.Release)
            {
                m_HeldLengths.Remove(inputAction.Input);
            }
        }
    }
}
