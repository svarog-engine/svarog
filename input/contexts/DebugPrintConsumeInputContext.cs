using svarog.input.events;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace svarog.input.contexts
{
    internal class DebugPrintConsumeInputContext : IGameContext
    {
        public IGameEvent? Interpret(IInput input)
        {
            Console.WriteLine(input);
            return default(DoNothingGameEvent);
        }
    }
}
