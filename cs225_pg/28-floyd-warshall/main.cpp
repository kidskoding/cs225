// main.cpp

#include "FloydWarshall.h"

#include <cstddef>
#include <iomanip>
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

/** Prints a matrix of distances (INF as "inf") or, if `asVertices`, of vertex names
 * Runtime: O(n^2)
 */
void printMatrix(const std::string& label, const floydwarshall::Matrix& m, bool asVertices = false) {
    std::cout << label << ":\n";
    for(size_t u = 0; u < m.size(); u++) {
        std::cout << "  " << name(u) << ":";
        for(int x : m[u]) {
            if(asVertices) {
                std::cout << " " << (x == -1 ? "-" : name(x));
            } else if(x == floydwarshall::INF) {
                std::cout << std::setw(4) << "inf";
            } else {
                std::cout << std::setw(4) << x;
            }
        }
        std::cout << "\n";
    }
}

/** Floyd-Warshall on the 4 vertex graph: distances, first steps, a path, and a negative cycle
 * Runtime: O(n^3)
 */
int main() {
    std::cout << "\n== Floyd Warshall's Algorithm ==\n";

    using floydwarshall::Edge;
    std::vector<Edge> edges = {{0, 1, -1}, {1, 2, 4}, {1, 3, 3}, {2, 3, -2}, {3, 0, 2}};

    printMatrix("distances", floydwarshall::floydWarshall(4, edges));
    floydwarshall::floydWarshallWithPaths(4, edges);
    printMatrix("next", floydwarshall::next, true);
    printVertices("path(D, C)", floydwarshall::path(3, 2));
    std::cout << "hasNegativeCycle(): " << std::boolalpha << floydwarshall::hasNegativeCycle() << "\n";

    edges[1].weight = -4; // B -> C makes A -> B -> C -> D -> A cost -5
    floydwarshall::floydWarshallWithPaths(4, edges);
    printMatrix("with B -> C = -4", floydwarshall::d);
    std::cout << "hasNegativeCycle(): " << floydwarshall::hasNegativeCycle() << std::noboolalpha << "\n";
    return 0;
}
