// Dijkstra.cpp

#include "Dijkstra.h"
#include <functional>
#include <limits>
#include <queue>
#include <utility>

namespace dijkstra {

/** Finds shortest distances from `s` with a lazy heap, skipping stale entries
 * (modified Dijkstra's: also correct with negative edges, as long as there is no negative cycle).
 * Unreachable vertices get `INT_MAX` and a predecessor of -1
 * Runtime: O(m log n)
 */
std::vector<int> dijkstra(const std::vector<std::vector<Edge>>& adj, int s, std::vector<int>& pred) {
    const int INF = std::numeric_limits<int>::max();
    std::vector<int> dist(adj.size(), INF);
    pred.assign(adj.size(), -1);
    dist[s] = 0;

    // (distance, vertex) pairs, with the smallest distance on top
    std::priority_queue<std::pair<int, int>, std::vector<std::pair<int, int>>, std::greater<>> pq;
    pq.push({0, s});

    while(!pq.empty()) {
        auto [d, u] = pq.top();
        pq.pop();
        if(d > dist[u]) { continue; } // stale: we already found a cheaper path to u

        for(const Edge& e : adj[u]) {
            // relax: going through `u` is a shorter path to `e.to`
            if(dist[u] + e.weight < dist[e.to]) {
                dist[e.to] = dist[u] + e.weight;
                pred[e.to] = u;
                pq.push({dist[e.to], e.to});
            }
        }
    }
    return dist;
}

/** Finds shortest distances from `s`, using an unsorted array as the queue
 * (standard Dijkstra's: needs non-negative weights)
 * Runtime: O(n^2)
 */
std::vector<int> dijkstraArray(const std::vector<std::vector<Edge>>& adj, int s, std::vector<int>& pred) {
    const int INF = std::numeric_limits<int>::max();
    int n = adj.size();
    std::vector<int> dist(n, INF);
    std::vector<bool> done(n, false);
    pred.assign(n, -1);
    dist[s] = 0;

    for(int step = 0; step < n; step++) {
        // removeMin: scan every vertex we haven't finished
        int u = -1;
        for(int v = 0; v < n; v++) {
            if(!done[v] && dist[v] != INF && (u == -1 || dist[v] < dist[u])) { u = v; }
        }
        if(u == -1) { break; } // everything left is unreachable
        done[u] = true;

        for(const Edge& e : adj[u]) {
            // relax: going through `u` is a shorter path to `e.to`
            if(!done[e.to] && dist[u] + e.weight < dist[e.to]) {
                dist[e.to] = dist[u] + e.weight;
                pred[e.to] = u;
            }
        }
    }
    return dist;
}

}
