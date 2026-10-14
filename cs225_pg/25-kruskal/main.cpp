// main.cpp

#include "Kruskal.h"

#include <iostream>
#include <string>
#include <vector>

/** Returns the letter name of vertex `v` (0 is A, 1 is B, ...)
 * Runtime: O(1)
 */
std::string name(int v) {
    return std::string(1, char('A' + v));
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

/** Turns edges written like "A-D:2" into Kruskal edges
 * Runtime: O(m)
 */
std::vector<kruskal::Edge> parseEdges(const std::vector<std::string>& edges) {
    std::vector<kruskal::Edge> out;
    for(const std::string& e : edges) {
        out.push_back({e[0] - 'A', e[2] - 'A', std::stoi(e.substr(4))});
    }
    return out;
}

/** The town from the Kruskal chapter, with every road written as "house-house:cost" */
const std::vector<std::string> townRoads = {
    "A-D:2", "E-H:3", "F-G:4", "A-B:5", "B-D:6", "G-E:7", "G-H:8",
    "E-C:9", "C-H:10", "E-F:11", "D-E:12", "A-C:13", "B-E:14"
};

/** Kruskal's algorithm on the town: the edges it adds and the total weight
 * Runtime: O(m log m)
 */
int main() {
    std::cout << "\n== MST: Kruskal's Algorithm ==\n";

    std::vector<kruskal::Edge> roads = parseEdges(townRoads);
    std::vector<kruskal::Edge> tree = kruskal::kruskal(8, roads);
    std::cout << "edges added:";
    for(const kruskal::Edge& e : tree) {
        std::cout << " " << name(e.u) << name(e.v) << "(" << e.weight << ")";
    }
    std::cout << "\ntotal weight: " << totalWeight(tree) << "\n";
    std::cout << "with a heap instead of sorting: " << totalWeight(kruskal::kruskalHeap(8, roads)) << "\n";
    return 0;
}
