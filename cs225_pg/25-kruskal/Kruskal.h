// Kruskal.h

#pragma once
#include <cstddef>
#include <queue>
#include <vector>

/** Kruskal's minimum spanning tree algorithm, on a graph given as a list of weighted edges */
namespace kruskal {

/** A weighted undirected edge between vertices u and v (numbered 0 to n - 1) */
struct Edge {
    int u;
    int v;
    int weight;
};

/** A comparison that makes `std::priority_queue` a min-heap of edges by weight */
struct HeavierThan {
    /** Returns whether `a` is heavier than `b`
     * (max-heap by default, so heavier edges count as smaller, which puts the lightest on top)
     * Runtime: O(1)
     */
    bool operator()(const Edge& a, const Edge& b) const {
        return a.weight > b.weight;
    }
};

using EdgeHeap = std::priority_queue<Edge, std::vector<Edge>, HeavierThan>;

/** Builds a minimum spanning tree from the cheapest edges that skip cycles,
 * using a sorted edge list as the priority queue
 * Runtime: O(m log m)
 */
std::vector<Edge> kruskal(size_t n, std::vector<Edge> edges);

/** Builds a minimum spanning tree from the cheapest edges that skip cycles,
 * using a heap (built in O(m) with buildHeap) as the priority queue
 * Runtime: O(m log m)
 */
std::vector<Edge> kruskalHeap(size_t n, std::vector<Edge> edges);

}
