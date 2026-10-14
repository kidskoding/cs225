// Graph.h

#pragma once
#include <list>
#include <string>
#include <vector>

/** An undirected graph stored as an adjacency list: a vector of vertices, a list of edges,
 * and for every vertex a doubly linked list of its incident edges, all linked by iterators
 */
class Graph {
public:
    /** the extra data each vertex stores (here, just a name) */
    using Vertex = std::string;

    struct Edge;

    /** points to an edge in the edge list */
    using EdgeIt = std::list<Edge>::iterator;

    /** An edge, which knows its two endpoints and where it sits in both of their adjacency lists */
    struct Edge {
        int u;
        int v;
        std::list<EdgeIt>::iterator uEntry; // this edge's entry in u's adjacency list
        std::list<EdgeIt>::iterator vEntry; // this edge's entry in v's adjacency list
    };

    /** Adds a vertex with no edges, reusing a removed vertex's number if there is one,
     * and returns the vertex's number
     * Runtime: O(1)
     */
    int insertVertex(const Vertex& data);

    /** Adds an edge between u and v
     * Runtime: O(1)
     */
    void insertEdge(int u, int v);

    /** Removes an edge we already have
     * Runtime: O(1)
     */
    void removeEdge(EdgeIt e);

    /** Removes the edge between v1 and v2 (if there is one), searching the shorter adjacency list
     * Runtime: O(min(deg(v1), deg(v2)))
     */
    void removeEdge(int v1, int v2);

    /** Removes vertex v and every edge incident on it
     * Runtime: O(deg(v))
     */
    void removeVertex(int v);

    /** Returns the edges incident on v
     * Runtime: O(deg(v))
     */
    const std::list<EdgeIt>& incidentEdges(int v);

    /** Checks whether there's an edge between v1 and v2
     * Runtime: O(min(deg(v1), deg(v2)))
     */
    bool areAdjacent(int v1, int v2);

    /** Returns the data stored with vertex v
     * Runtime: O(1)
     */
    const Vertex& vertex(int v) const;

    /** Returns the number of vertices in the graph (not counting removed ones)
     * Runtime: O(1)
     */
    int numVertices() const;

    /** Returns the number of edges in the graph
     * Runtime: O(1)
     */
    int numEdges() const;

private:
    /** vertex i is stored at index i */
    std::vector<Vertex> vertices;

    /** adj[i] is the adjacency list of vertex i */
    std::vector<std::list<EdgeIt>> adj;

    /** every edge in the graph */
    std::list<Edge> edges;

    /** removed[i] is true if vertex i has been tombstoned */
    std::vector<bool> removed;

    /** the numbers of tombstoned vertices, which `insertVertex` reuses first */
    std::vector<int> available;
};
