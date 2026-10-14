// Dijkstra.h

#pragma once
#include <vector>

/** Dijkstra's single-source shortest paths, on a directed weighted adjacency list */
namespace dijkstra {

/** One entry of an adjacency list: the vertex the edge goes to, and its weight */
struct Edge {
    int to;
    int weight;
};

/** Finds shortest distances from `s` with a lazy heap, skipping stale entries
 * (modified Dijkstra's: also correct with negative edges, as long as there is no negative cycle).
 * Unreachable vertices get `INT_MAX` and a predecessor of -1
 * Runtime: O(m log n)
 */
std::vector<int> dijkstra(const std::vector<std::vector<Edge>>& adj, int s, std::vector<int>& pred);

/** Finds shortest distances from `s`, using an unsorted array as the queue
 * (standard Dijkstra's: needs non-negative weights)
 * Runtime: O(n^2)
 */
std::vector<int> dijkstraArray(const std::vector<std::vector<Edge>>& adj, int s, std::vector<int>& pred);

}
