// FloydWarshall.h

#pragma once
#include <limits>
#include <vector>

/** Floyd-Warshall all-pairs shortest paths, with path recovery and negative cycle detection */
namespace floydwarshall {

/** the largest `int` stands in for infinity (no known path) */
const int INF = std::numeric_limits<int>::max();

/** A directed weighted edge from u to v (vertices numbered 0 to n - 1) */
struct Edge {
    int u;
    int v;
    int weight;
};

using Matrix = std::vector<std::vector<int>>;

/** the distance matrix filled in by `floydWarshallWithPaths` */
extern Matrix d;

/** next[u][v] is the first vertex on the best path from u to v (-1 if there is no path) */
extern Matrix next;

/** Finds the shortest distance between every pair of vertices
 * Runtime: O(n^3)
 */
Matrix floydWarshall(int n, const std::vector<Edge>& edges);

/** Fills `d` with all-pairs shortest distances and `next` with first steps
 * Runtime: O(n^3)
 */
void floydWarshallWithPaths(int n, const std::vector<Edge>& edges);

/** Follows `next` from `u` to rebuild the shortest path to `v` (empty if there is no path)
 * Runtime: O(n) (one step per edge on the path)
 */
std::vector<int> path(int u, int v);

/** Returns whether any vertex can reach itself for a negative cost
 * Runtime: O(n)
 */
bool hasNegativeCycle();

}
