#import "../diagrams.typ": array-cells, graph, tree

#let ex-nodes = (A: (0, 0), B: (1.5, 1.4), C: (1.5, 0), D: (1.5, -1.4), E: (3, 1.4), F: (3, 0), H: (3, -1.4), G: (4.5, 0))
#let ex-edges = ("A-B", "A-C", "A-D", "B-C", "B-E", "C-D", "C-E", "C-F", "D-F", "D-H", "E-G", "F-G", "G-H")
#let bfs-discovery = ("A-B", "A-C", "A-D", "B-E", "C-F", "D-H", "E-G")
#let bfs-cross = ("B-C", "C-D", "C-E", "D-F", "F-G", "G-H")
#let dfs-discovery = ("A-B", "B-C", "C-D", "D-F", "F-G", "E-G", "G-H")
#let dfs-back = ("A-C", "A-D", "B-E", "C-E", "C-F", "D-H")

= Graph Traversals

In MP Traversals, we've been traversing an image: start at a pixel, visit its neighbors, and if we've already been somewhere, don't go there again. We pretended the image was basically a tree, with a patch for "don't go back where you've been". But that patch is exactly what a real graph traversal does. Now let's write the actual graph algorithms, *breadth-first search* (BFS) and *depth-first search* (DFS)

Just like traversing a list or an AVL tree, traversing a graph means visiting all of its data, and a graph's data is its vertices *and* its edges. So a graph traversal looks at every vertex and every edge

== Labeling the Graph

The graph versions of these algorithms do more than visit vertices: they also *label* every edge with how the traversal used it. So we keep a label on every vertex and every edge

- Every vertex starts *unexplored*, and becomes *visited* when the traversal reaches it. This is the "have I been here before?" structure you built in MP Traversals
- Every edge starts *unexplored*. If the traversal uses an edge to reach a new vertex, it becomes a *discovery edge*. If the edge leads somewhere the traversal had already reached, it becomes a *cross edge* in BFS, or a *back edge* in DFS (we'll see why they get different names)

Do we need the edge labels? Not to traverse: without them, it's the same algorithm, since we can always just check whether we've been to a vertex before. We keep them because the labeled graph is the *output*, and the labels tell us a lot about the graph. In MP Traversals we didn't care about the edges at all, only the vertices, and there's nothing wrong with that either

=== Traversing Every Component

A flood fill in MP Traversals has a start location, and it only reaches what it can get to from there. A traversal of the *whole* graph might have to start from every vertex, since the graph might not be connected. Think of a graph with 100 vertices and no edges at all. It's not a very exciting graph, but it could happen, and the only way to explore it is to start from vertex 0, then start from vertex 1, and so on. So a full traversal is a wrapper around a helper

+ Label every vertex and every edge as unexplored
+ For each vertex `v`, if `v` is still unexplored, run the traversal starting from `v`

The helper explores everything it can reach from `v`, which is `v`'s whole connected component, while the wrapper makes sure every component gets explored. We call both of these "BFS" (or "DFS"), to be as confusing as possible, given that they're doing quite different jobs

== Breadth-First Search

BFS uses a *queue* as its working data structure. Instead of just vertices, the queue holds pairs: a vertex, and the edge we found it by. That way, when we pull a vertex out, we know which edge to label as its discovery edge. The starting vertex goes in with no edge, since we got there from nowhere

=== An Example

@gtraversal-example shows the graph we'll use for the rest of this chapter. We'll assume each adjacency list is in alphabetical order, so that's the order we look at neighbors in

#figure(
  grid(
    columns: 2,
    column-gutter: 4em,
    align: center + horizon,
    graph(ex-nodes, ex-edges),
    table(
      columns: 2,
      table.header([*Vertex*], [*Adjacent Vertices*]),
      [$A$], [$B$, $C$, $D$],
      [$B$], [$A$, $C$, $E$],
      [$C$], [$A$, $B$, $D$, $E$, $F$],
      [$D$], [$A$, $C$, $F$, $H$],
      [$E$], [$B$, $C$, $G$],
      [$F$], [$C$, $D$, $G$],
      [$G$], [$E$, $F$, $H$],
      [$H$], [$D$, $G$],
    ),
  ),
  caption: [Example: the graph we'll traverse in this chapter (left), and its adjacency lists in alphabetical order (right)],
) <gtraversal-example>

Along with the labels, we'll keep track of two things for every vertex

- $d$, the *distance*: how many edges we took to get from the start to this vertex
- $p$, the *predecessor*: the vertex we came from right before reaching this one

Let's run BFS starting from $A$. In the queue, we'll write the pair "vertex $C$, found by the edge from $B$" as $B -> C$. We start by putting $A$ in the queue (with no edge), and then

- Dequeue $A$. It's unexplored, so we visit it, with $d = 0$ and no predecessor. All of its neighbors, $B$, $C$, and $D$, are unexplored, so they all go in the queue
- Dequeue $A -> B$. $B$ is unexplored, so we visit it, and $A B$ is the edge that discovered it, so $A B$ is a discovery edge. $B$'s predecessor is $A$, and its distance is one more than $A$'s, so $d = 1$. Now we look at $B$'s neighbors. $A$ has already been visited, so we skip it. $C$ hasn't been visited yet (it's in the queue, but nobody has pulled it out), so $B -> C$ goes in, and so does $B -> E$
- $C$ and $D$ come out next, the same way, with $d = 1$ and $p = A$
- Dequeue $B -> C$. We've already visited $C$, so we don't do anything with it. The edge $B C$ led somewhere we'd already been, so it's a cross edge

The table shows every step. Each row is one dequeue, and the queue is written front first

#table(
  columns: (auto, 1fr, 1fr),
  table.header([*Dequeued*], [*What Happens*], [*Queue Afterwards*]),
  [$A$], [Visit $A$: $d = 0$, no predecessor], [$A -> B$, $A -> C$, $A -> D$],
  [$A -> B$], [Visit $B$: $d = 1$, $p = A$, $A B$ is a discovery edge], [$A -> C$, $A -> D$, $B -> C$, $B -> E$],
  [$A -> C$], [Visit $C$: $d = 1$, $p = A$, $A C$ is a discovery edge], [$A -> D$, $B -> C$, $B -> E$, $C -> D$, $C -> E$, $C -> F$],
  [$A -> D$], [Visit $D$: $d = 1$, $p = A$, $A D$ is a discovery edge], [$B -> C$, $B -> E$, $C -> D$, $C -> E$, $C -> F$, $D -> F$, $D -> H$],
  [$B -> C$], [$C$ was already visited, so $B C$ is a cross edge], [$B -> E$, $C -> D$, $C -> E$, $C -> F$, $D -> F$, $D -> H$],
  [$B -> E$], [Visit $E$: $d = 2$, $p = B$, $B E$ is a discovery edge], [$C -> D$, $C -> E$, $C -> F$, $D -> F$, $D -> H$, $E -> G$],
  [$C -> D$], [$C D$ is a cross edge], [$C -> E$, $C -> F$, $D -> F$, $D -> H$, $E -> G$],
  [$C -> E$], [$C E$ is a cross edge], [$C -> F$, $D -> F$, $D -> H$, $E -> G$],
  [$C -> F$], [Visit $F$: $d = 2$, $p = C$, $C F$ is a discovery edge], [$D -> F$, $D -> H$, $E -> G$, $F -> G$],
  [$D -> F$], [$D F$ is a cross edge], [$D -> H$, $E -> G$, $F -> G$],
  [$D -> H$], [Visit $H$: $d = 2$, $p = D$, $D H$ is a discovery edge], [$E -> G$, $F -> G$, $H -> G$],
  [$E -> G$], [Visit $G$: $d = 3$, $p = E$, $E G$ is a discovery edge], [$F -> G$, $H -> G$],
  [$F -> G$], [$F G$ is a cross edge], [$H -> G$],
  [$H -> G$], [$G H$ is a cross edge], [Empty, so we're done],
)

Notice how $G$ ended up in the queue three times, once for each way we found it. Only the first copy to come out visits it, and the other two just label their edges as cross edges

@gtraversal-bfs-steps shows the same run as pictures. Visited vertices are shaded, discovery edges are bold, and cross edges are dashed. BFS visits $A$, then everything one edge away from $A$, then everything two edges away, and finally $G$, three edges away. It spreads out from the start in *layers*, which is where the name breadth-first comes from

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 1em,
    align: center + horizon,
    graph(ex-nodes, ex-edges, highlight: ("A",)),
    graph(ex-nodes, ex-edges, highlight: ("A", "B", "C", "D"), bold: ("A-B", "A-C", "A-D")),
    [(a) Visit $A$ ($d = 0$)], [(b) Visit $B$, $C$, and $D$ ($d = 1$)],
    graph(
      ex-nodes,
      ex-edges,
      highlight: ("A", "B", "C", "D", "E", "F", "H"),
      bold: ("A-B", "A-C", "A-D", "B-E", "C-F", "D-H"),
      dashed: ("B-C", "C-D", "C-E", "D-F"),
    ),
    graph(ex-nodes, ex-edges, highlight: ("A", "B", "C", "D", "E", "F", "G", "H"), bold: bfs-discovery, dashed: bfs-cross),
    [(c) Visit $E$, $F$, and $H$ ($d = 2$)], [(d) Visit $G$ ($d = 3$)],
  ),
  caption: [BFS from $A$ on the graph in @gtraversal-example. Visited vertices are shaded, discovery edges are bold, and cross edges are dashed],
) <gtraversal-bfs-steps>

When we're done, every vertex has been visited, and every edge has been labeled as either a discovery edge or a cross edge. @gtraversal-bfs-tree pulls out just the discovery edges, along with every vertex's $d$ and $p$

#figure(
  grid(
    columns: 2,
    column-gutter: 4em,
    align: center + horizon,
    tree(("A", ("B", ("E", "G")), ("C", "F"), ("D", "H"))),
    table(
      columns: 3,
      align: center,
      table.header([*Vertex*], [$d$], [$p$]),
      [$A$], [0], [None],
      [$B$], [1], [$A$],
      [$C$], [1], [$A$],
      [$D$], [1], [$A$],
      [$E$], [2], [$B$],
      [$F$], [2], [$C$],
      [$G$], [3], [$E$],
      [$H$], [2], [$D$],
    ),
  ),
  caption: [The discovery edges from @gtraversal-bfs-steps drawn as a tree rooted at $A$ (left), and the distance and predecessor of every vertex (right). Each level of the tree is one distance from $A$],
) <gtraversal-bfs-tree>

=== The Algorithm

To run BFS starting from a vertex `s`

+ Put `s` in an empty queue, with no edge
+ While the queue isn't empty, dequeue a vertex `v` and the edge `e` we found it by, and
  + If `v` is unexplored, mark it visited and label `e` (if there is one) as a discovery edge. Then, for every edge `f` incident on `v`, if the vertex `w` on its other end is still unexplored, enqueue `w` along with `f`
  + Otherwise, `v` was already visited, so `e` led somewhere we'd already been, and we label it as a cross edge

=== When to Mark a Vertex Visited

Many of you marked a pixel as visited in MP Traversals when you *added* it to the queue, not when you took it out. For BFS, that gives exactly the same result, and it's a nice optimization. The first time we find a vertex, it goes in the queue, and since a queue is first in, first out, that's the copy of it that comes out first anyway. Marking it early just keeps the later copies out of the queue

But that only works because BFS uses a queue. As we'll see, DFS is the same algorithm with a stack, and with a stack, the copy that comes out first is the *last* one that went in. So marking a vertex when it goes in changes which edge discovers it. We want one algorithm that works for both, so we mark vertices when they come *out*

=== The Code

In the code, the graph is an adjacency list, where `adj[v]` holds the numbers of the edges incident on `v`, and each edge knows its two endpoints. The labels live in two vectors indexed by vertex and edge number, and we use $-1$ for "no edge"

```cpp
// BFS.cpp

enum class Label { UNEXPLORED, VISITED, DISCOVERY, CROSS, BACK };

struct Edge {
    int u;
    int v;
    int other(int w) const { return w == u ? v : u; }
};

struct Graph {
    std::vector<Edge> edges;
    std::vector<std::vector<int>> adj; // adj[v] holds the numbers of v's incident edges
    int size() const { return adj.size(); }
};

std::vector<Label> vLabel;
std::vector<Label> eLabel;

/** Runs BFS from start, labeling everything it can reach
 * Runtime: O(n + m)
 */
void BFS(const Graph& g, int start) {
    std::queue<std::pair<int, int>> q; // (vertex, edge we found it by)
    q.push({start, -1});
    while (!q.empty()) {
        auto [v, e] = q.front();
        q.pop();
        if (vLabel[v] == Label::UNEXPLORED) {
            // mark v visited when it comes out, so the same code works for DFS
            vLabel[v] = Label::VISITED;
            if (e != -1) { eLabel[e] = Label::DISCOVERY; }
            for (int f : g.adj[v]) {
                int w = g.edges[f].other(v);
                // only queue neighbors we haven't visited yet
                if (vLabel[w] == Label::UNEXPLORED) { q.push({w, f}); }
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
    vLabel.assign(g.size(), Label::UNEXPLORED);
    eLabel.assign(g.edges.size(), Label::UNEXPLORED);
    for (int v = 0; v < g.size(); v++) {
        // start a new BFS from any vertex the earlier ones didn't reach
        if (vLabel[v] == Label::UNEXPLORED) { BFS(g, v); }
    }
}
```

This doesn't keep track of $d$ and $p$, since we don't need them just to traverse. How would we find them? The predecessor of `v` is the other end of the edge we found it by, which is exactly why we store that edge in the queue. And its distance is one more than its predecessor's. So to keep track of them too, we add two lines right after marking `v` as visited

```cpp
// we came from the other end of e
p[v] = (e == -1) ? -1 : g.edges[e].other(v);
// one more edge than our predecessor
d[v] = (e == -1) ? 0 : d[p[v]] + 1;
```

== What BFS Tells Us

The labeled graph we get from BFS tells us a lot about the graph

=== Shortest Paths

What's the shortest path from $A$ to $H$? BFS already found it. Starting at $H$, its predecessor is $D$, and $D$'s predecessor is $A$. Reading that backwards, the path is $A$, $D$, $H$, which takes 2 edges, exactly $H$'s distance $d$

```cpp
// BFS.cpp

/** Returns a shortest path from the start of the BFS to end
 * Runtime: O(n)
 */
std::vector<int> pathTo(int end) {
    std::vector<int> path;
    // follow the predecessors back to the start, which has none
    for (int v = end; v != -1; v = p[v]) {
        path.push_back(v);
    }
    // we built the path backwards
    std::reverse(path.begin(), path.end());
    return path;
}
```

So if we store the predecessors (or even just the discovery edges), we can recover a shortest path from the start of the BFS to any vertex. This only works because it's a breadth-first search on an *unweighted* graph, where the shortest path is the one with the fewest edges

What about the shortest path from $E$ to $H$? This BFS doesn't tell us anything about it. It only knows shortest paths from $A$ to everything else (or, since the graph is undirected, from everything else to $A$). To learn about paths from $E$, we'd have to run another BFS starting from $E$

=== Cross Edges

Our cross edges are $B C$, $C D$, $C E$, $D F$, $F G$, and $G H$. Look at the distances of their endpoints: $B$ and $C$ are both 1, while $D F$ goes from 1 to 2. In fact, the distances at the two ends of a cross edge *never* differ by more than one

Why? BFS finds everything that's one edge away from the start before anything that's two edges away, and everything that's two edges away before anything that's three away. Suppose some edge connected a vertex $x$ to a vertex $y$ with $d(y) >= d(x) + 2$. When we visited $x$, $y$ hadn't been found yet (it's farther away), so we'd have put $y$ in the queue right then, and it would have come out at distance $d(x) + 1$. So that edge would have been the discovery edge for $y$, not a cross edge

For example, if we added an edge between $A$ and $G$ to the graph and ran BFS again, $G$ would be discovered straight from $A$ at distance 1, and $E G$ would become a cross edge instead

=== Spanning Trees, Components, and Cycles

- *Spanning trees* - The vertices with just the discovery edges form a tree, like in @gtraversal-bfs-tree: every vertex other than the start was discovered exactly once, by one edge. If the graph is connected, that tree reaches every vertex, so it's a *spanning tree*. Our graph has 8 vertices and 7 discovery edges, which is exactly $n - 1$
- *Connected components* - The wrapper starts a new BFS once for every connected component, so counting how many times it starts one counts the components
- *Cycles* - If there's a cross edge, the graph has a cycle. A cross edge connects two vertices that were already connected through the tree, so adding it closes a loop. For example, cross edge $B C$ closes the cycle $A$, $B$, $C$, $A$. If the graph is a tree, BFS never finds a cross edge, no matter where it starts
- *Distances* - $d$ is the length of the shortest path from the start to every vertex

That's a lot of information from one algorithm!

== Running Time of BFS

How long does BFS take? Let's start with the obvious analysis of the code

- Labeling every vertex and every edge as unexplored is $O(n)$ and $O(m)$
- The wrapper's loop runs $n$ times, calling the helper each time
- In the helper, the `while` loop runs once per dequeue. Every vertex has to come out of the queue at least once, and some come out more than once, so let's say $O(n)$
- Inside it, the `for` loop runs once per incident edge, and a vertex can have up to $n - 1$ of those, so that's $O(n)$ too

Three nested loops that each run $O(n)$ times gives $O(n^3)$. That would be a terrible algorithm! Everything we said is true, but it misses something: this isn't some arbitrary data structure, it's a graph, and the loops limit each other

- The body of the `if` runs exactly *once per vertex* over the whole traversal, no matter how many times the wrapper calls the helper, since once a vertex is visited, it never becomes unexplored again
- So the `for` loop runs $deg(v)$ times for each vertex $v$, and only once per vertex. In total, it runs $sum_(v in V) deg(v) = 2m$ times
- A vertex only goes in the queue when one of its neighbors is visited and looks at the edge between them, so it can go in at most once per incident edge (plus once if it's a starting point). In total, the queue gets at most $n + 2m$ things, so the `while` loop runs at most $n + 2m$ times, across *every* call of the helper

So the total is $O(n) + O(m) + O(n) + O(n + 2m) + O(2m) = O(n + m)$, not $O(n^3)$. In the worst case, a graph where every vertex is connected to every other vertex has $m approx n^2 / 2$, so that's $O(n^2)$. But $O(n + m)$ is optimal: a traversal wants to visit every vertex and every edge, and that's exactly how much work it does

The trick is to step back from the code and think about what the algorithm does. It goes to every vertex once and looks at every edge incident on it. Even if we could teleport straight to every vertex, that's $n$ vertices plus every edge twice (once from each end), $n + 2m$. The number of times one loop runs affects how many times the other loops can run, even though they're nested, because the structure of the graph doesn't change

This also answers what graph implementation BFS wants. The analysis assumes `incidentEdges(v)` takes $O(deg(v))$, which is what an adjacency list gives us. With an adjacency matrix, finding the neighbors of each vertex means checking its whole row, which is $O(n)$ per vertex and $O(n^2)$ in total, no matter how few edges there are. With an edge list, it's $O(m)$ per vertex, or $O(n m)$ in total

== Depth-First Search

DFS explores the same graph a different way. The easiest way to think about it is recursively: when we visit a vertex, we go through its neighbors, and for each one, we immediately run DFS on it, before moving on to the next neighbor

=== An Example

Let's run DFS from $A$ on the graph in @gtraversal-example, again looking at neighbors in alphabetical order

- Visit $A$. Its first neighbor is $B$, so $A B$ is a discovery edge and we call DFS on $B$
- $B$'s first neighbor is $A$, but we came from there along $A B$, which is already labeled. So we move on to $C$, and $B C$ is a discovery edge
- $C$'s first neighbor is $A$, which has already been visited, so $A C$ is a *back edge*. Then we skip $B$ (we came from there), and $C D$ is a discovery edge
- From $D$, $A D$ is a back edge, and $D F$ is a discovery edge
- From $F$, $C F$ is a back edge, and $F G$ is a discovery edge
- From $G$, $E G$ is a discovery edge
- From $E$, $B E$ and $C E$ are both back edges, and $E$ has nothing else to explore, so we return to $G$
- $G$ still has one more neighbor to try, so $G H$ is a discovery edge. From $H$, $D H$ is a back edge
- Now everything returns, all the way back to $A$. Every time we return to a vertex, we check the rest of its neighbors, but all of their edges have been labeled by now, so there's nothing left to do

So DFS visits $A$, $B$, $C$, $D$, $F$, $G$, $E$, $H$. It goes as far (as *deep*) as it can before it starts working its way back up, which is where the name depth-first comes from. The recursive calls form a stack, and @gtraversal-dfs-stack shows the graph and the call stack at the moment DFS first reaches $E$

#figure(
  grid(
    columns: 2,
    column-gutter: 4em,
    align: center + horizon,
    graph(
      ex-nodes,
      ex-edges,
      highlight: ("A", "B", "C", "D", "E", "F", "G"),
      bold: ("A-B", "B-C", "C-D", "D-F", "F-G", "E-G"),
      dashed: ("A-C", "A-D", "C-F"),
    ),
    array-cells($A$, $B$, $C$, $D$, $F$, $G$, $E$),
  ),
  caption: [DFS from $A$ at the moment it first reaches $E$ (left), and the call stack at that moment, with $A$ at the bottom (right). The number under each vertex is its distance from $A$ in the DFS tree],
) <gtraversal-dfs-stack>

@gtraversal-dfs-result shows the final labeling. Just like BFS, every vertex has been visited, and every edge is either a discovery edge or a back edge

#figure(
  graph(ex-nodes, ex-edges, highlight: ("A", "B", "C", "D", "E", "F", "G", "H"), bold: dfs-discovery, dashed: dfs-back),
  caption: [The result of DFS from $A$. Discovery edges are bold, and back edges are dashed],
) <gtraversal-dfs-result>

=== Back Edges

DFS also produces a tree out of its discovery edges, shown in @gtraversal-dfs-tree. If we keep track of the distance from $A$ in that tree, we get $A = 0$, $B = 1$, $C = 2$, $D = 3$, $F = 4$, $G = 5$, and $E = H = 6$

#figure(
  grid(
    columns: 2,
    column-gutter: 4em,
    align: center + horizon,
    tree(("A", ("B", ("C", ("D", ("F", ("G", "E", "H"))))))),
    table(
      columns: 3,
      align: center,
      table.header([*Vertex*], [$d$], [$p$]),
      [$A$], [0], [None],
      [$B$], [1], [$A$],
      [$C$], [2], [$B$],
      [$D$], [3], [$C$],
      [$E$], [6], [$G$],
      [$F$], [4], [$D$],
      [$G$], [5], [$F$],
      [$H$], [6], [$G$],
    ),
  ),
  caption: [The discovery edges from @gtraversal-dfs-result drawn as a tree rooted at $A$ (left), and every vertex's distance and predecessor in that tree (right)],
) <gtraversal-dfs-tree>

Those distances don't have much to do with shortest paths. $E$ is 6 edges from $A$ in the DFS tree, but only 2 edges away in the graph ($A$, $B$, $E$). Compare the long, skinny DFS tree in @gtraversal-dfs-tree with the short, bushy BFS tree in @gtraversal-bfs-tree: the DFS distances only describe paths in the DFS tree, not in the whole graph. Back edges don't have the nice "at most one apart" property of cross edges either. The back edge $B E$ connects distances 1 and 6, a difference of 5

That's why these get a different name. A cross edge goes *across*, to a vertex at roughly the same level. A back edge always goes *back up*, to an ancestor of the current vertex in the DFS tree, so the vertex on the other end always has a smaller distance. Notice in @gtraversal-dfs-stack that when $E$ finds its back edges $B E$ and $C E$, both $B$ and $C$ are still on the call stack. That's always true. If a back edge led to a vertex that had already finished and returned, then that vertex, while it was still exploring, would have followed the same edge and discovered us first

How far back a back edge goes isn't something we can predict, so it doesn't tell us about shortest paths. But one thing works just like a cross edge: if DFS finds a back edge, the graph has a cycle. If the graph is a tree, there's no cycle, so neither BFS nor DFS will ever find a cross edge or a back edge, no matter where they start. And just like BFS, the discovery edges form a spanning tree if the graph is connected, and the wrapper starts DFS once per connected component

=== From BFS to DFS

Here's the code for DFS

```cpp
// DFS.cpp

/** Runs DFS from start, labeling everything it can reach
 * Runtime: O(n + m)
 */
void DFS(const Graph& g, int start) {
    // a stack instead of a queue
    std::stack<std::pair<int, int>> s; // (vertex, edge we found it by)
    s.push({start, -1});
    while (!s.empty()) {
        auto [v, e] = s.top();
        s.pop();
        if (vLabel[v] == Label::UNEXPLORED) {
            vLabel[v] = Label::VISITED;
            if (e != -1) { eLabel[e] = Label::DISCOVERY; }
            for (int f : g.adj[v]) {
                int w = g.edges[f].other(v);
                if (vLabel[w] == Label::UNEXPLORED) { s.push({w, f}); }
            }
        } else {
            // a back edge instead of a cross edge
            eLabel[e] = Label::BACK;
        }
    }
}
```

How could we possibly understand such a massive change? The queue became a stack, `front` became `top`, and cross edges became back edges. That's it! The wrapper is the same too, just calling `DFS` instead of `BFS`. This is the heart of MP Traversals: you're really writing one algorithm, and plugging in either a stack or a queue

There's one small difference from the example. A stack pops whatever was pushed *last*, so this version tries a vertex's neighbors in reverse order. From $A$, it goes to $D$ first, and visits $A$, $D$, $H$, $G$, $F$, $C$, $E$, $B$. That's still a depth-first search, it just tries neighbors in the opposite order from the run in @gtraversal-dfs-result. If we wanted the same order as the example, we'd push the neighbors in reverse

=== The Recursive Version

What about the recursive version we ran in the example? Start from the stack version, and

- Remove the stack, the loop, and the pop, since the recursion does all of that for us
- Instead of pushing a vertex and its edge onto the stack, make a recursive call on them, which uses the *call stack* instead

```cpp
// DFS.cpp

/** Runs DFS from v, which we reached by the edge e
 * Runtime: O(n + m)
 */
void DFS(const Graph& g, int v, int e) {
    if (vLabel[v] == Label::UNEXPLORED) {
        vLabel[v] = Label::VISITED;
        if (e != -1) { eLabel[e] = Label::DISCOVERY; }
        for (int f : g.adj[v]) {
            // check the edge, not the vertex, so the call can find back edges
            if (eLabel[f] == Label::UNEXPLORED) { DFS(g, g.edges[f].other(v), f); }
        }
    } else {
        // we already visited v, so e goes back to an ancestor
        eLabel[e] = Label::BACK;
    }
}
```

The wrapper calls `DFS(g, v, -1)` for every vertex that's still unexplored

The body is the same, except for one detail: the check before the call looks at the *edge*, not the vertex. In the stack version, we pushed `w` while it was still unexplored, and by the time it came back out, it might have been visited along another path, which is how back edges got labeled. A recursive call happens *right away*, so if we only called on unexplored vertices, we'd never reach the `else`, and back edges would never get labeled. So instead, we call on every edge we haven't labeled yet, and let the call find out that its vertex was already visited. The edge we came in on is already a discovery edge, so we never walk straight back along it

Going in this direction makes it look easy. Going the other way, from a recursive DFS to an iterative one, is trickier, since we have to figure out exactly what needs to go on the stack, and when we've actually "gotten" somewhere. But it's interesting that the same algorithm can turn from one into the other with so few lines of code

=== Running Time of DFS

We don't need a new analysis. Every operation on a stack is $O(1)$, just like on a queue, and we put exactly the same number of things in and take the same number out. Every vertex gets visited once, and every edge gets looked at once from each end. So DFS is also $O(n + m)$, with an adjacency list

And that's how we traverse a graph: with either breadth-first or depth-first search, both in $O(n + m)$ time
