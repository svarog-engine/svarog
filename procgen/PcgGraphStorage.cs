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
        MultiDictionary<string, uint> m_NamedConnectionsByName = new();
        Dictionary<string, PcgTransform> m_Procedures = new();
        public HashSet<uint> Nodes => m_Nodes;

        public static ulong CombineNodeIds(uint a, uint b) => (ulong)a << 32 | (ulong)b;
        public static (uint, uint) ExtractNodeIds(ulong ab) => ((uint)(ab >> 32), (uint)ab);

        public bool HasAnnotation(uint n, string annotation) => m_Annotated.ContainsKey(n) && m_Annotated[n].Contains(annotation);
        public uint AddNode(string? annotation)
        {
            m_CurrentId++;
            m_Nodes.Add(m_CurrentId);
            if (annotation != null)
            {
                m_Annotated.Add(m_CurrentId, annotation);
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
                m_NamedConnections.Add(m_CurrentId, name);
                m_NamedConnectionsByName.Add(name, m_CurrentId);
            }

            return m_CurrentId;
        }

        public ulong GetEndpoints(uint c)
        {
            return m_ArrowEndpoints[c];
        }

        public void RemoveConn(uint c)
        {
            if (m_ArrowEndpoints.TryGetValue(c, out ulong connId))
            {
                if (m_NamedConnections.ContainsKey(c))
                {
                    foreach (var n in m_NamedConnections[c])
                    {
                        m_NamedConnectionsByName[n].Remove(c);
                    }
                    m_NamedConnections.Remove(c);
                }
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


        public int GetInDegree(uint n)
        {
            if (m_ArrowSources.ContainsKey(n))
            {
                return m_ArrowSources[n].Count;
            }

            return 0;
        }

        public int GetOutDegree(uint n)
        {
            if (m_ArrowTargets.ContainsKey(n))
            {
                return m_ArrowTargets[n].Count;
            }

            return 0;
        }

        public List<uint> GetArrowIdFromConnectionId(ulong connId)
        {
            return m_Arrows[connId];
        }

        public int CountArrowsCalled(string name)
        {
            if (m_NamedConnectionsByName.ContainsKey(name))
            {
                return m_NamedConnectionsByName[name].Count;
            }

            return 0;
        }

        public IEnumerable<uint> GetArrowsCalled(string name)
        {
            if (m_NamedConnectionsByName.ContainsKey(name))
            {
                foreach (var conn in m_NamedConnectionsByName[name])
                {
                    yield return conn;
                }
            }
        }

        public uint GetSource(uint arrow)
        {
            return ExtractNodeIds(m_ArrowEndpoints[arrow]).Item1;
        }

        public uint GetTarget(uint arrow)
        {
            return ExtractNodeIds(m_ArrowEndpoints[arrow]).Item2;
        }

        public IEnumerable<uint> GetArrowsFrom(uint n)
        {
            if (m_ArrowSources.ContainsKey(n))
            {
                foreach (var arr in m_ArrowSources[n])
                {
                    yield return arr;
                }
            }
        }

        public IEnumerable<uint> GetArrowsTo(uint n)
        {
            if (m_ArrowTargets.ContainsKey(n))
            {
                foreach (var arr in m_ArrowTargets[n])
                {
                    yield return arr;
                }
            }
        }

        public void AddAnnotation(uint n, string newAnn)
        {
            m_Annotated.Add(n, newAnn);
        }

        public void RemoveAnnotation(uint n)
        {
            m_Annotated.Remove(n);
        }

        public PcgTransform? GetProc(string name) => m_Procedures[name];

        public void LoadProcs(string text)
        {
            PcgParseOutput? procs = new PcgParser().Parse(text);
            if (procs.HasValue)
            {
                foreach (var proc in procs.Value.procs)
                {
                    m_Procedures[proc.Name] = proc.Transform;
                }
            }
        }

    }
}
