// Traversal.h

#pragma once
#include <vector>

/** Breadth-first and depth-first search on a numbered graph, labeling every vertex and edge */
namespace traversal {

/** How a traversal has used a vertex or an edge */
enum class Label { UNEXPLORED, VISITED, DISCOVERY, CROSS, BACK };

/** An undirected edge between two vertex numbers */
struct Edge {
    int u;
    int v;

    /** Returns the endpoint of this edge that isn't `w`
     * Runtime: O(1)
     */
    int other(int w) const { return w == u ? v : u; }
};

/** A graph stored as an adjacency list of edge numbers */
struct Graph {
    std::vector<Edge> edges;
    std::vector<std::vector<int>> adj; // adj[v] holds the numbers of v's incident edges

    /** Returns the number of vertices
     * Runtime: O(1)
     */
    int size() const { return adj.size(); }

    /** Adds an edge between u and v to the end of both of their adjacency lists
     * Runtime: O(1)
     */
    void insertEdge(int u, int v) {
        edges.push_back({u, v});
        adj[u].push_back(edges.size() - 1);
        adj[v].push_back(edges.size() - 1);
    }
};

/** the label of every vertex */
extern std::vector<Label> vLabel;

/** the label of every edge */
extern std::vector<Label> eLabel;

/** the distance of every vertex from the start of its traversal, in the traversal's tree */
extern std::vector<int> d;

/** the predecessor of every vertex in the traversal's tree (-1 for none) */
extern std::vector<int> p;

/** the vertices in the order the last traversal visited them */
extern std::vector<int> visitOrder;

/** Labels every vertex and edge unexplored, and clears `d`, `p`, and `visitOrder`
 * Runtime: O(n + m)
 */
void initLabels(const Graph& g);

/** Runs BFS from start, labeling everything it can reach
 * Runtime: O(n + m)
 */
void BFS(const Graph& g, int start);

/** Runs BFS on every connected component of g
 * Runtime: O(n + m)
 */
void BFS(const Graph& g);

/** Returns a shortest path from the start of the BFS to end
 * Runtime: O(n)
 */
std::vector<int> pathTo(int end);

/** Runs DFS from start with an explicit stack, labeling everything it can reach
 * Runtime: O(n + m)
 */
void DFS(const Graph& g, int start);

/** Runs DFS from v, which we reached by the edge e (-1 for the start), using recursion
 * Runtime: O(n + m)
 */
void DFS(const Graph& g, int v, int e);

/** Runs the recursive DFS on every connected component of g
 * Runtime: O(n + m)
 */
void DFS(const Graph& g);

}
