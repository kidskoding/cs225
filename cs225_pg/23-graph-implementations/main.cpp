// main.cpp

#include "Graph.h"

#include <iostream>

/** Graph implementations: the adjacency list on the graph u, v, w, z
 * Runtime: O(n + m)
 */
int main() {
    std::cout << "\n== Graph Implementations ==\n";

    Graph g;
    int u = g.insertVertex("u");
    int v = g.insertVertex("v");
    int w = g.insertVertex("w");
    int z = g.insertVertex("z");
    g.insertEdge(u, v);
    g.insertEdge(u, w);
    g.insertEdge(v, w);
    g.insertEdge(w, z);

    std::cout << "incidentEdges(w) lead to:";
    for(Graph::EdgeIt e : g.incidentEdges(w)) {
        std::cout << " " << g.vertex(e->u == w ? e->v : e->u);
    }
    std::cout << "\n" << std::boolalpha;
    std::cout << "areAdjacent(u, z): " << g.areAdjacent(u, z) << "\n";
    std::cout << "areAdjacent(v, w): " << g.areAdjacent(v, w) << "\n";
    g.removeEdge(v, w);
    std::cout << "removeEdge(v, w), then areAdjacent(v, w): " << g.areAdjacent(v, w) << "\n";
    g.removeVertex(w);
    std::cout << "removeVertex(w): numVertices " << g.numVertices() << ", numEdges " << g.numEdges() << "\n";
    int x = g.insertVertex("x");
    std::cout << "insertVertex(x) reuses number " << x << "\n" << std::noboolalpha;
    return 0;
}
