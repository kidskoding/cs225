// Prim.h

#pragma once
#include <vector>

/** Prim's minimum spanning tree algorithm, on a weighted adjacency list */
namespace prim {

/** One entry of an adjacency list: the vertex on the other end, and the edge's weight */
struct Edge {
    int to;
    int weight;
};

using Graph = std::vector<std::vector<Edge>>; // g[v] holds v's incident edges

/** Builds a minimum spanning tree from `s` and returns each vertex's parent (-1 for `s`)
 * Runtime: O(m log n)
 */
std::vector<int> prim(const Graph& g, int s);

}
