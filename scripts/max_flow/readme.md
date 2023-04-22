A basic implementation of the Ford Fulkerson algorithm in Python:

```python
from collections import deque

def bfs(graph, source, sink, parent):
    visited = [False] * len(graph)
    queue = deque()
    queue.append(source)
    visited[source] = True
    while queue:
        u = queue.popleft()
        for idx, val in enumerate(graph[u]):
            if not visited[idx] and val > 0:
                queue.append(idx)
                visited[idx] = True
                parent[idx] = u
    return visited[sink]

def ford_fulkerson(graph, source, sink):
    parent = [-1] * len(graph)
    max_flow = 0
    while bfs(graph, source, sink, parent):
        path_flow = float("Inf")
        s = sink
        while s != source:
            path_flow = min(path_flow, graph[parent[s]][s])
            s = parent[s]
        max_flow += path_flow
        v = sink
        while v != source:
            u = parent[v]
            graph[u][v] -= path_flow
            graph[v][u] += path_flow
            v = parent[v]
    return max_flow
```

The `bfs` function performs a Breadth-First Search to find an augmenting path in the residual graph. It returns `True` if there exists a path from the source to the sink, and sets the parent array to the path that was found.

The `ford_fulkerson` function initializes the parent array and the maximum flow to 0. It then repeatedly runs the BFS algorithm to find augmenting paths in the residual graph, until no more paths can be found. For each augmenting path, it calculates the path flow and updates the residual graph accordingly. The function returns the maximum flow that was found.

To use this algorithm, you need to represent your graph as an adjacency matrix where `graph[i][j]` represents the capacity of the edge from node `i` to node `j`. The `source` and `sink` nodes should be specified as integers.

For example, to find the maximum flow in a graph with 4 nodes and 5 edges, where node 0 is the source and node 3 is the sink, you could call the `ford_fulkerson` function like this:

```python
graph = [[0, 3, 0, 3, 0],
         [0, 0, 4, 0, 0],
         [0, 0, 0, 1, 2],
         [0, 0, 0, 0, 2],
         [0, 0, 0, 0, 0]]
source = 0
sink = 3
max_flow = ford_fulkerson(graph, source, sink)
print("Maximum flow:", max_flow)
```

This would output `Maximum flow: 5`, which is the maximum flow that can be sent from the source to the sink in this graph.