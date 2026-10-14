// Graph.cpp

#include "Graph.h"
#include <utility>

/** Adds a vertex with no edges, reusing a removed vertex's number if there is one,
 * and returns the vertex's number
 * Runtime: O(1)
 */
int Graph::insertVertex(const Vertex& data) {
    // reuse a tombstoned number before growing the vector
    if(!available.empty()) {
        int v = available.back();
        available.pop_back();
        vertices[v] = data;
        removed[v] = false;
        return v;
    }

    vertices.push_back(data);
    // a new vertex starts with an empty adjacency list
    adj.push_back({});
    removed.push_back(false);
    return vertices.size() - 1;
}

/** Adds an edge between u and v
 * Runtime: O(1)
 */
void Graph::insertEdge(int u, int v) {
    EdgeIt e = edges.insert(edges.end(), Edge{u, v, {}, {}});

    // add the edge to both endpoints' lists, and remember where it went in each
    e->uEntry = adj[u].insert(adj[u].end(), e);
    e->vEntry = adj[v].insert(adj[v].end(), e);
}

/** Removes an edge we already have
 * Runtime: O(1)
 */
void Graph::removeEdge(EdgeIt e) {
    // remove the edge's entries from both adjacency lists before the edge itself
    adj[e->u].erase(e->uEntry);
    adj[e->v].erase(e->vEntry);
    edges.erase(e);
}

/** Removes the edge between v1 and v2 (if there is one), searching the shorter adjacency list
 * Runtime: O(min(deg(v1), deg(v2)))
 */
void Graph::removeEdge(int v1, int v2) {
    // an STL list knows its size, so we can pick the shorter list in O(1)
    if(adj[v1].size() > adj[v2].size()) { std::swap(v1, v2); }
    for(EdgeIt e : adj[v1]) {
        if(e->u == v2 || e->v == v2) {
            removeEdge(e);
            return;
        }
    }
}

/** Removes vertex v and every edge incident on it
 * Runtime: O(deg(v))
 */
void Graph::removeVertex(int v) {
    // removing an edge erases it from this list, so keep removing the front one
    while(!adj[v].empty()) {
        removeEdge(adj[v].front());
    }

    // then tombstone vertex v, like in the edge list
    removed[v] = true;
    available.push_back(v);
}

/** Returns the edges incident on v
 * Runtime: O(deg(v))
 */
const std::list<Graph::EdgeIt>& Graph::incidentEdges(int v) {
    return adj[v];
}

/** Checks whether there's an edge between v1 and v2
 * Runtime: O(min(deg(v1), deg(v2)))
 */
bool Graph::areAdjacent(int v1, int v2) {
    // make v1 the endpoint with the shorter adjacency list
    if(adj[v1].size() > adj[v2].size()) { std::swap(v1, v2); }
    for(EdgeIt e : adj[v1]) {
        // e's other end is v2 exactly when one of its endpoints is v2
        if(e->u == v2 || e->v == v2) { return true; }
    }
    return false;
}

/** Returns the data stored with vertex v
 * Runtime: O(1)
 */
const Graph::Vertex& Graph::vertex(int v) const {
    return vertices[v];
}

/** Returns the number of vertices in the graph (not counting removed ones)
 * Runtime: O(1)
 */
int Graph::numVertices() const {
    return vertices.size() - available.size();
}

/** Returns the number of edges in the graph
 * Runtime: O(1)
 */
int Graph::numEdges() const {
    return edges.size();
}
