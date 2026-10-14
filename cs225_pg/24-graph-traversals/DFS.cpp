// DFS.cpp

#include "Traversal.h"
#include <stack>
#include <utility>

namespace traversal {

/** Runs DFS from start with an explicit stack, labeling everything it can reach
 * Runtime: O(n + m)
 */
void DFS(const Graph& g, int start) {
    // a stack instead of a queue
    std::stack<std::pair<int, int>> s; // (vertex, edge we found it by)
    s.push({start, -1});

    while(!s.empty()) {
        auto [v, e] = s.top();
        s.pop();

        if(vLabel[v] == Label::UNEXPLORED) {
            vLabel[v] = Label::VISITED;
            visitOrder.push_back(v);
            if(e != -1) { eLabel[e] = Label::DISCOVERY; }
            p[v] = (e == -1) ? -1 : g.edges[e].other(v);
            d[v] = (e == -1) ? 0 : d[p[v]] + 1;

            for(int f : g.adj[v]) {
                int w = g.edges[f].other(v);
                if(vLabel[w] == Label::UNEXPLORED) { s.push({w, f}); }
            }
        } else {
            // a back edge instead of a cross edge
            eLabel[e] = Label::BACK;
        }
    }
}

/** Runs DFS from v, which we reached by the edge e (-1 for the start), using recursion
 * Runtime: O(n + m)
 */
void DFS(const Graph& g, int v, int e) {
    if(vLabel[v] == Label::UNEXPLORED) {
        vLabel[v] = Label::VISITED;
        visitOrder.push_back(v);
        if(e != -1) { eLabel[e] = Label::DISCOVERY; }
        p[v] = (e == -1) ? -1 : g.edges[e].other(v);
        d[v] = (e == -1) ? 0 : d[p[v]] + 1;

        for(int f : g.adj[v]) {
            // check the edge, not the vertex, so the call can find back edges
            if(eLabel[f] == Label::UNEXPLORED) { DFS(g, g.edges[f].other(v), f); }
        }
    } else {
        // we already visited v, so e goes back to an ancestor
        eLabel[e] = Label::BACK;
    }
}

/** Runs the recursive DFS on every connected component of g
 * Runtime: O(n + m)
 */
void DFS(const Graph& g) {
    initLabels(g);
    for(int v = 0; v < g.size(); v++) {
        // start a new DFS from any vertex the earlier ones didn't reach
        if(vLabel[v] == Label::UNEXPLORED) { DFS(g, v, -1); }
    }
}

}
