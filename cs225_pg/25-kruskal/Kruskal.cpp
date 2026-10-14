// Kruskal.cpp

#include "Kruskal.h"
#include "../21-disjoint-sets/DisjointSets.h"
#include <algorithm>
#include <utility>

namespace kruskal {

/** Builds a minimum spanning tree from the cheapest edges that skip cycles,
 * using a sorted edge list as the priority queue
 * Runtime: O(m log m)
 */
std::vector<Edge> kruskal(size_t n, std::vector<Edge> edges) {
    DisjointSets forest;
    forest.addElements(n);

    // a sorted list is a priority queue, as long as we never insert
    std::sort(edges.begin(), edges.end(), [](const Edge& a, const Edge& b) {
        return a.weight < b.weight;
    });

    std::vector<Edge> tree;
    size_t next = 0;

    // stop once the tree has n - 1 edges or we run out of edges
    while(tree.size() < n - 1 && next < edges.size()) {
        Edge e = edges[next++];
        int ru = forest.find(e.u);
        int rv = forest.find(e.v);

        // different roots: the edge joins two trees, so it can't make a cycle
        if(ru != rv) {
            tree.push_back(e);
            forest.unionBySize(ru, rv);
        }
    }
    return tree;
}

/** Builds a minimum spanning tree from the cheapest edges that skip cycles,
 * using a heap (built in O(m) with buildHeap) as the priority queue
 * Runtime: O(m log m)
 */
std::vector<Edge> kruskalHeap(size_t n, std::vector<Edge> edges) {
    DisjointSets forest;
    forest.addElements(n);

    // building from the whole vector at once runs buildHeap in O(m)
    EdgeHeap pq(HeavierThan(), std::move(edges));

    std::vector<Edge> tree;
    while(tree.size() < n - 1 && !pq.empty()) {
        // removeMin: the lightest edge is on top
        Edge e = pq.top();
        pq.pop();
        int ru = forest.find(e.u);
        int rv = forest.find(e.v);
        if(ru != rv) {
            tree.push_back(e);
            forest.unionBySize(ru, rv);
        }
    }
    return tree;
}

}
