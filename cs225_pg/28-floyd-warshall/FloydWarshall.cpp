// FloydWarshall.cpp

#include "FloydWarshall.h"

namespace floydwarshall {

Matrix d;
Matrix next;

/** Finds the shortest distance between every pair of vertices
 * Runtime: O(n^3)
 */
Matrix floydWarshall(int n, const std::vector<Edge>& edges) {
    Matrix d(n, std::vector<int>(n, INF));

    // a vertex reaches itself for 0, and each edge is the best path known yet
    for(int v = 0; v < n; v++) {
        d[v][v] = 0;
    }
    for(const Edge& e : edges) {
        d[e.u][e.v] = e.weight;
    }

    // allow one more middle vertex `k` per pass, so `k` must be the outer loop
    for(int k = 0; k < n; k++) {
        for(int u = 0; u < n; u++) {
            for(int v = 0; v < n; v++) {
                // no known path through `k` (adding to INF would overflow)
                if(d[u][k] == INF || d[k][v] == INF) { continue; }
                if(d[u][k] + d[k][v] < d[u][v]) {
                    d[u][v] = d[u][k] + d[k][v];
                }
            }
        }
    }
    return d;
}

/** Fills `d` with all-pairs shortest distances and `next` with first steps
 * Runtime: O(n^3)
 */
void floydWarshallWithPaths(int n, const std::vector<Edge>& edges) {
    d.assign(n, std::vector<int>(n, INF));
    next.assign(n, std::vector<int>(n, -1));
    for(int v = 0; v < n; v++) {
        d[v][v] = 0;
        next[v][v] = v;
    }
    for(const Edge& e : edges) {
        d[e.u][e.v] = e.weight;
        next[e.u][e.v] = e.v;
    }

    // allow one more middle vertex `k` per pass, so `k` must be the outer loop
    for(int k = 0; k < n; k++) {
        for(int u = 0; u < n; u++) {
            for(int v = 0; v < n; v++) {
                // no known path through `k` (adding to INF would overflow)
                if(d[u][k] == INF || d[k][v] == INF) { continue; }
                if(d[u][k] + d[k][v] < d[u][v]) {
                    d[u][v] = d[u][k] + d[k][v];
                    // first step toward `v` is now the first step toward `k`
                    next[u][v] = next[u][k];
                }
            }
        }
    }
}

/** Follows `next` from `u` to rebuild the shortest path to `v` (empty if there is no path)
 * Runtime: O(n) (one step per edge on the path)
 */
std::vector<int> path(int u, int v) {
    // -1 means there is no path from `u` to `v`
    if(next[u][v] == -1) { return {}; }
    std::vector<int> p = {u};
    while(u != v) {
        u = next[u][v];
        p.push_back(u);
    }
    return p;
}

/** Returns whether any vertex can reach itself for a negative cost
 * Runtime: O(n)
 */
bool hasNegativeCycle() {
    for(size_t v = 0; v < d.size(); v++) {
        // a negative diagonal entry means `v` sits on a negative weight cycle
        if(d[v][v] < 0) { return true; }
    }
    return false;
}

}
