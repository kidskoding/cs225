// main.cpp

#include "Dijkstra.h"

#include <cstddef>
#include <iostream>
#include <string>
#include <vector>

/** Returns the letter name of vertex `v` (0 is A, 1 is B, ...)
 * Runtime: O(1)
 */
std::string name(int v) {
    return std::string(1, char('A' + v));
}

/** Prints a list of vertex numbers by their letter names
 * Runtime: O(n)
 */
void printVertices(const std::string& label, const std::vector<int>& vertices) {
    std::cout << label << ":";
    for(int v : vertices) {
        std::cout << " " << name(v);
    }
    std::cout << "\n";
}

/** Builds the directed graph from the Dijkstra chapter, with `hg` as the weight of H -> G
 * Runtime: O(m)
 */
std::vector<std::vector<dijkstra::Edge>> dijkstraGraph(int hg) {
    std::vector<std::vector<dijkstra::Edge>> adj(8);
    const std::vector<std::string> edges = {
        "A>B:10", "A>F:7", "F>B:2", "F>G:4", "B>C:3", "B>D:8",
        "G>D:4", "C>D:5", "C>E:5", "D>H:4", "E>H:1"
    };
    for(const std::string& e : edges) {
        adj[e[0] - 'A'].push_back({e[2] - 'A', std::stoi(e.substr(4))});
    }
    adj['H' - 'A'].push_back({'G' - 'A', hg});
    return adj;
}

/** Prints every vertex's distance and predecessor from a Dijkstra run
 * Runtime: O(n)
 */
void printShortestPaths(const std::string& label, const std::vector<int>& dist, const std::vector<int>& pred) {
    std::cout << label << ":";
    for(size_t v = 0; v < dist.size(); v++) {
        std::cout << " " << name(v) << "=" << dist[v] << "(" << (pred[v] == -1 ? "-" : name(pred[v])) << ")";
    }
    std::cout << "\n";
}

/** Dijkstra's algorithm from A, with and without the negative edge H -> G
 * Runtime: O(m log n)
 */
int main() {
    std::cout << "\n== Dijkstra's Algorithm ==\n";

    std::vector<int> pred;
    std::vector<int> dist = dijkstra::dijkstra(dijkstraGraph(1), 0, pred);
    printShortestPaths("lazy heap", dist, pred);
    std::vector<int> path;
    for(int v = 'H' - 'A'; v != -1; v = pred[v]) {
        path.insert(path.begin(), v);
    }
    printVertices("shortest path to H", path);

    dist = dijkstra::dijkstraArray(dijkstraGraph(1), 0, pred);
    printShortestPaths("unsorted array", dist, pred);

    dist = dijkstra::dijkstraArray(dijkstraGraph(-8), 0, pred);
    printShortestPaths("H -> G = -8, standard (wrong G, D)", dist, pred);
    dist = dijkstra::dijkstra(dijkstraGraph(-8), 0, pred);
    printShortestPaths("H -> G = -8, modified", dist, pred);
    return 0;
}
