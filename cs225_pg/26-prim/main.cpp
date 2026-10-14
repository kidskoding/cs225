// main.cpp

#include "../25-kruskal/Kruskal.h"
#include "Prim.h"

#include <iostream>
#include <string>
#include <vector>

/** Returns the letter name of vertex `v` (0 is a, 1 is b, ...)
 * Runtime: O(1)
 */
std::string name(int v) {
    return std::string(1, char('a' + v));
}

/** Returns the total weight of a list of Kruskal edges
 * Runtime: O(n)
 */
int totalWeight(const std::vector<kruskal::Edge>& edges) {
    int total = 0;
    for(const kruskal::Edge& e : edges) {
        total += e.weight;
    }
    return total;
}

/** Turns edges written like "a-d:3" into Kruskal edges
 * Runtime: O(m)
 */
std::vector<kruskal::Edge> parseEdges(const std::vector<std::string>& edges) {
    std::vector<kruskal::Edge> out;
    for(const std::string& e : edges) {
        out.push_back({e[0] - 'a', e[2] - 'a', std::stoi(e.substr(4))});
    }
    return out;
}

/** The graph from the Prim chapter, with every edge written as "vertex-vertex:weight" */
const std::vector<std::string> primEdges = {
    "a-b:12", "a-d:3", "a-f:14", "b-c:15", "b-d:5", "c-d:10", "c-e:7", "c-h:1",
    "d-e:4", "d-f:11", "e-f:13", "e-g:6", "e-h:9", "f-g:2", "g-h:8"
};

/** Prim's algorithm from a: every vertex's predecessor and the total weight
 * Runtime: O(m log n)
 */
int main() {
    std::cout << "\n== MST: Prim's Algorithm ==\n";

    std::vector<kruskal::Edge> edges = parseEdges(primEdges);
    prim::Graph g(8);
    for(const kruskal::Edge& e : edges) {
        g[e.u].push_back({e.v, e.weight});
        g[e.v].push_back({e.u, e.weight});
    }

    std::vector<int> p = prim::prim(g, 0);
    int total = 0;
    std::cout << "p:";
    for(int v = 0; v < 8; v++) {
        std::cout << " " << name(v) << "=" << (p[v] == -1 ? "-" : name(p[v]));
        for(const prim::Edge& e : g[v]) {
            if(e.to == p[v]) { total += e.weight; }
        }
    }
    std::cout << "\ntotal weight: " << total << "\n";
    std::cout << "Kruskal's on the same graph: " << totalWeight(kruskal::kruskal(8, edges)) << "\n";
    return 0;
}
