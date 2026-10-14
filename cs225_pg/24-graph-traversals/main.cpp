// main.cpp

#include "Traversal.h"

#include <cstddef>
#include <iostream>
#include <string>
#include <vector>

/** Returns the letter name of vertex `v` (0 is A, 1 is B, ...)
 * Runtime: O(1)
 */
std::string name(int v) {
    return std::string(1, char('A' + v));
}

/** Prints a list of vertex numbers by their letter names
 * Runtime: O(n)
 */
void printVertices(const std::string& label, const std::vector<int>& vertices) {
    std::cout << label << ":";
    for(int v : vertices) {
        std::cout << " " << name(v);
    }
    std::cout << "\n";
}

/** Builds the graph A to H from the traversals chapter, with alphabetical adjacency lists
 * Runtime: O(n + m)
 */
traversal::Graph traversalGraph() {
    traversal::Graph g;
    g.adj.resize(8);
    const char* edges[] = {"AB", "AC", "AD", "BC", "BE", "CD", "CE", "CF", "DF", "DH", "EG", "FG", "GH"};
    for(const char* e : edges) {
        g.insertEdge(e[0] - 'A', e[1] - 'A');
    }
    return g;
}

/** Prints the edges of `g` that have the label `label`
 * Runtime: O(m)
 */
void printEdges(const std::string& title, const traversal::Graph& g, traversal::Label label) {
    std::cout << title << ":";
    for(size_t e = 0; e < g.edges.size(); e++) {
        if(traversal::eLabel[e] == label) {
            std::cout << " " << name(g.edges[e].u) << name(g.edges[e].v);
        }
    }
    std::cout << "\n";
}

/** Prints every vertex's distance and predecessor from the last traversal
 * Runtime: O(n)
 */
void printDistances(const traversal::Graph& g) {
    std::cout << "d and p:";
    for(int v = 0; v < g.size(); v++) {
        std::cout << " " << name(v) << "=" << traversal::d[v]
                  << "(" << (traversal::p[v] == -1 ? "-" : name(traversal::p[v])) << ")";
    }
    std::cout << "\n";
}

/** Graph traversals: BFS and DFS (recursive and stack-based) on the graph A to H
 * Runtime: O(n + m)
 */
int main() {
    std::cout << "\n== Graph Traversals ==\n";

    using traversal::Label;
    traversal::Graph g = traversalGraph();

    traversal::BFS(g);
    printVertices("BFS visits", traversal::visitOrder);
    printDistances(g);
    printEdges("discovery edges", g, Label::DISCOVERY);
    printEdges("cross edges", g, Label::CROSS);
    printVertices("pathTo(H)", traversal::pathTo(7));

    traversal::DFS(g);
    printVertices("DFS (recursive) visits", traversal::visitOrder);
    printDistances(g);
    printEdges("discovery edges", g, Label::DISCOVERY);
    printEdges("back edges", g, Label::BACK);

    traversal::initLabels(g);
    traversal::DFS(g, 0);
    printVertices("DFS (stack) from A visits", traversal::visitOrder);
    return 0;
}
