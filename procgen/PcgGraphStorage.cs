using Universal.Common.Collections;

namespace svarog.procgen
{
    public class PcgGraphStorage
    {
        uint m_CurrentId = 0;

        HashSet<uint> m_Nodes = new();
        MultiDictionary<uint, string> m_Annotated = new();
        HashSet<ulong> m_Connected = new();
        MultiDictionary<uint, uint> m_ArrowSources = new();
        MultiDictionary<uint, uint> m_ArrowTargets = new();
        MultiDictionary<ulong, uint> m_Arrows = new();
        Dictionary<uint, ulong> m_ArrowEndpoints = new();
        MultiDictionary<uint, string> m_NamedConnections = new();

        private static ulong CombineNodeIds(uint a, uint b) => (ulong)a << 32 | (ulong)b;
        private static (uint, uint) ExtractNodeIds(ulong ab) => ((uint)(ab & uint.MaxValue), (uint)(ab >> 32));

        public uint AddNode(string? annotation)
        {
            m_CurrentId++;
            m_Nodes.Add(m_CurrentId);
            if (annotation != null)
            {
                m_Annotated[m_CurrentId].Add(annotation);
            }
            return m_CurrentId;
        }

        public uint AddConn(uint a, uint b, string? name)
        {
            m_CurrentId++;
            ulong connId = CombineNodeIds(a, b);
            m_Connected.Add(connId);
            m_Arrows.Add(connId, m_CurrentId);
            m_ArrowEndpoints.Add(m_CurrentId, connId);
            m_ArrowSources.Add(a, m_CurrentId);
            m_ArrowTargets.Add(b, m_CurrentId);
            if (name != null)
            {
                m_NamedConnections[m_CurrentId].Add(name);
            }

            return m_CurrentId;
        }

        public void RemoveConn(uint c)
        {
            if (m_ArrowEndpoints.TryGetValue(c, out ulong connId))
            {
                m_NamedConnections.Remove(c);
                m_Arrows[connId].Remove(c);
                var (a, b) = ExtractNodeIds(connId);
                m_ArrowSources[a].Remove(c);
                m_ArrowTargets[b].Remove(c);
                m_ArrowEndpoints.Remove(c);
            }
        }

        public void RemoveNode(uint n)
        {
            HashSet<uint> connections = [];
            foreach (uint c in m_ArrowSources[n])
            {
                connections.Add(c);
            }
            
            foreach (uint c in m_ArrowTargets[n])
            {
                connections.Add(c);
            }

            foreach (var c in connections) RemoveConn(c);
            m_Annotated.Remove(n);
            m_Nodes.Remove(n);
        }

        public void AddAnnotation(uint n, string newAnn)
        {
            m_Annotated.Add(n, newAnn);
        }

        public void RemoveAnnotation(uint n)
        {
            m_Annotated.Remove(n);
        }
    }
}
