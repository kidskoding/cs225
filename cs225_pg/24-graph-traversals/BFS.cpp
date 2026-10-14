// BFS.cpp

#include "Traversal.h"
#include <algorithm>
#include <queue>
#include <utility>

namespace traversal {

std::vector<Label> vLabel;
std::vector<Label> eLabel;
std::vector<int> d;
std::vector<int> p;
std::vector<int> visitOrder;

/** Labels every vertex and edge unexplored, and clears `d`, `p`, and `visitOrder`
 * Runtime: O(n + m)
 */
void initLabels(const Graph& g) {
    vLabel.assign(g.size(), Label::UNEXPLORED);
    eLabel.assign(g.edges.size(), Label::UNEXPLORED);
    d.assign(g.size(), -1);
    p.assign(g.size(), -1);
    visitOrder.clear();
}

/** Runs BFS from start, labeling everything it can reach
 * Runtime: O(n + m)
 */
void BFS(const Graph& g, int start) {
    std::queue<std::pair<int, int>> q; // (vertex, edge we found it by)
    q.push({start, -1});

    while(!q.empty()) {
        auto [v, e] = q.front();
        q.pop();

        if(vLabel[v] == Label::UNEXPLORED) {
            // mark v visited when it comes out, so the same code works for DFS
            vLabel[v] = Label::VISITED;
            visitOrder.push_back(v);
            if(e != -1) { eLabel[e] = Label::DISCOVERY; }

            // we came from the other end of e
            p[v] = (e == -1) ? -1 : g.edges[e].other(v);
            // one more edge than our predecessor
            d[v] = (e == -1) ? 0 : d[p[v]] + 1;

            for(int f : g.adj[v]) {
                int w = g.edges[f].other(v);
                // only queue neighbors we haven't visited yet
                if(vLabel[w] == Label::UNEXPLORED) { q.push({w, f}); }
            }
        } else {
            // we already reached v by another edge, so e leads somewhere we've been
            eLabel[e] = Label::CROSS;
        }
    }
}

/** Runs BFS on every connected component of g
 * Runtime: O(n + m)
 */
void BFS(const Graph& g) {
    initLabels(g);
    for(int v = 0; v < g.size(); v++) {
        // start a new BFS from any vertex the earlier ones didn't reach
        if(vLabel[v] == Label::UNEXPLORED) { BFS(g, v); }
    }
}

/** Returns a shortest path from the start of the BFS to end
 * Runtime: O(n)
 */
std::vector<int> pathTo(int end) {
    std::vector<int> path;
    // follow the predecessors back to the start, which has none
    for(int v = end; v != -1; v = p[v]) {
        path.push_back(v);
    }
    // we built the path backwards
    std::reverse(path.begin(), path.end());
    return path;
}

}
