// Prim.cpp

#include "Prim.h"
#include "VertexHeap.h"
#include <climits>

namespace prim {

/** Builds a minimum spanning tree from `s` and returns each vertex's parent (-1 for `s`)
 * Runtime: O(m log n)
 */
std::vector<int> prim(const Graph& g, int s) {
    int n = g.size();
    std::vector<int> d(n, INT_MAX); // INT_MAX stands in for infinity
    std::vector<int> p(n, -1);      // -1 means no predecessor
    std::vector<bool> inTree(n, false);
    d[s] = 0;

    VertexHeap q(d); // buildHeap on all n vertices, ordered by d
    for(int i = 0; i < n; i++) {
        // the cheapest vertex left is the next one added to the tree
        int m = q.removeMin();
        inTree[m] = true;

        for(const Edge& e : g[m]) {
            int v = e.to;
            // found a cheaper edge connecting `v` to the tree
            if(!inTree[v] && e.weight < d[v]) {
                d[v] = e.weight;
                p[v] = m;
                q.decreaseKey(v, d[v]);
            }
        }
    }
    return p;
}

}
