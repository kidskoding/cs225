#import "../diagrams.typ": array-cells, graph, linked-list

#let example-nodes = (u: (0, 1.2), v: (0, 0), w: (1.4, 0.6), z: (2.8, 0.6))
#let example-edges = ("u-v", "u-w", "v-w", "w-z")

= Graph Implementations

Recall that in this class, a *path* is any sequence of vertices connected by edges, even with repeats, and a *simple path* never repeats a vertex (theory classes call these a *walk* and a *path*). Everything else about graphs is the same as classical graph theory

== The Graph ADT

What does a graph data structure need to do? Its operations fall into two groups

*Changing the graph*

- `insertVertex` and `removeVertex`
- `insertEdge` and `removeEdge`

*Asking about the graph*

- `incidentEdges(v)` - The edges that touch `v`. This is basically the same as asking for `v`'s *adjacent vertices*, since from one we can get the other, so which one we use depends on the algorithm
- `areAdjacent(v1, v2)` - Is there an edge between `v1` and `v2`? This is exactly what MP Traversals asks when it checks whether a neighbor is within the tolerance: if it's not, there is no edge, so the traversal doesn't go there
- `origin(e)` and `destination(e)` - Only for *directed* graphs, where an edge from $u$ to $v$ is different from an edge from $v$ to $u$. A simple directed graph can have both, since there's still at most one edge from the same place to the same place

In practice, applications often don't use a general graph data structure through these operations. Our other data structures (like an AVL tree mid-rotation) are allowed to be invalid in the *middle* of an operation, but if `insertVertex` and friends are an exposed interface, the graph has to be valid after every single one, which controls their runtime. Real code often makes a huge batch of changes at once, where the graph might be nonsense in the middle, as long as it's a proper graph again by the end

== Storing the Vertices

Vertices can have any names, but just like with disjoint sets, our graph data structures always number the vertices $0$ to $n - 1$. If they have real names, we keep a separate dictionary that maps each name to its number. That way, finding vertex 7 is just going to index 7 of an array, which is $O(1)$

Each vertex can store whatever extra data we want, like a name, a color, or a weight. In MP Traversals, the vertices are pixels, and the extra data is each pixel's color. That data is useful, but it isn't part of the *structure* of the graph

== Edge List

The simplest idea follows the definition of a graph exactly: $G = (V, E)$ is a set of vertices and a set of edges. So we store

- A vector of *vertices*, where vertex $i$ is at index $i$
- A linked list of *edges*. Each edge can store whatever extra data we want, but it *must* store its two endpoints, by their vertex numbers

@graph-edge-list stores a small graph with four vertices, $u$, $v$, $w$, and $z$, numbered 0 through 3

#figure(
  grid(
    columns: 3,
    column-gutter: 3em,
    align: center + horizon,
    graph(example-nodes, example-edges),
    array-cells("u", "v", "w", "z"),
    table(
      columns: 2,
      table.header([*Edge*], [*Endpoints*]),
      [$a$], [0, 1],
      [$b$], [0, 2],
      [$c$], [1, 2],
      [$d$], [2, 3],
    ),
  ),
  caption: [Example: a graph (left) stored as an edge list: a vector of its vertices (middle) and a list of its edges, each storing its two endpoints (right)],
) <graph-edge-list>

```cpp
struct Edge {
    int u;
    int v;
    // plus any extra edge data, like a weight
};

std::vector<Vertex> vertices; // vertex i is stored at index i
std::list<Edge> edges;
```

It clearly holds all of the information about the graph, since it's exactly the theoretical definition. So how fast is it?

- `insertVertex` - Just `push_back` onto the vertex vector, which is $O(1)$
- `removeVertex` - First, we have to deal with the vertex itself. Shifting everything in the vector over would be a mess, so instead we use *tombstoning*: mark the vertex as gone and add its number to a list of available numbers, which `insertVertex` reuses before pushing back. That's $O(1)$, and the only cost is that the vector never shrinks below the most vertices we've ever had. But we're not done: an edge must have both endpoints in the graph, so we also have to remove every edge incident on the vertex. The only way to find them is to check every edge, so `removeVertex` is $O(m)$
- `insertEdge` - Add the edge to the front (or back) of the edge list. The list has no order, so this is $O(1)$
- `removeEdge(v1, v2)` - If all we know is the endpoints, we have to check every edge until we find it, which is $O(m)$. Tombstoning the edge wouldn't help, since *finding* it is the slow part
- `incidentEdges(v)` - Walk through the whole edge list and return every edge that touches `v`, which is $O(m)$
- `areAdjacent(v1, v2)` - Walk through the edge list looking for an edge with both endpoints, which is $O(m)$

So we can build a graph in $O(1)$ per operation, but everything else is $O(m)$, which is terrible. Remember that exploring a graph means looking at the incident edges of every vertex, which here takes $O(n m)$ time even if we do nothing else. That could be $O(n^3)$!

Notice that `insertEdge` doesn't check whether the edge already exists. That's a design decision. With our C++ glasses on, we assume the caller knows what they're doing, just like `vector`'s square brackets don't check whether the index is in bounds. In an edge list, checking would make every `insertEdge` cost $O(m)$, which makes loading a graph slow. If we were building an interface where users click to add edges, checking might be worth it

=== The Edge List as a File Format

So why talk about such a slow data structure? Because almost every program that uses graphs needs to *save* and *load* them, and for that, the edge list is perfect. To save a graph, write every vertex, then every edge, and that's the file. To load it, add every vertex and every edge, each in $O(1)$ time, which is as fast as just reading the file

Almost every graph data set you'll find is stored this way. Really large graphs are stored in binary, but most graphs are small enough to store as text, with one vertex per line followed by one edge per line

```
0 u red 4.5
1 v blue 2.0
2 w red 1.5
3 z green 3.0
0 1
0 2
1 2
2 3
```

Each vertex line starts with the vertex number and then any data we store with it (like a name, color, and weight), and each edge line is its two endpoints followed by any data we store with it

== Adjacency Matrix

The edge list has all of the information, it's just slow to search. So we keep it and add an *index*: an $n times n$ *adjacency matrix*, where entry $(i, j)$ says whether there's an edge between vertex $i$ and vertex $j$

Two improvements make the matrix more useful

- In an undirected graph, entry $(i, j)$ and entry $(j, i)$ are the same edge, so we only need half of the matrix (say, where $i < j$). That doesn't change the $O(n^2)$ space, but it does cut it in half
- Instead of storing just true or false, each entry stores a *pointer* to the edge in the edge list (or `nullptr` if there's no edge). Since the edge list is a linked list, following that pointer lets us remove the edge in $O(1)$

@graph-adjacency-matrix shows the adjacency matrix for the graph from @graph-edge-list

#figure(
  table(
    columns: 5,
    align: center,
    [], [*0 ($u$)*], [*1 ($v$)*], [*2 ($w$)*], [*3 ($z$)*],
    [*0 ($u$)*], table.cell(fill: luma(235))[], [$a$], [$b$], [],
    [*1 ($v$)*], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], [$c$], [],
    [*2 ($w$)*], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], [$d$],
    [*3 ($z$)*], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[],
  ),
  caption: [The adjacency matrix for the graph in @graph-edge-list. Each entry points to the edge between those two vertices, empty entries are `nullptr`, and the shaded half is never used in an undirected graph],
) <graph-adjacency-matrix>

Now our operations are

- `incidentEdges(v)` - Check every entry in `v`'s row (or, if we only store half the matrix, the bent row and column that belong to `v`). That's $O(n)$ instead of $O(m)$. $m$ can be smaller than $n$, but in a connected graph, which is what we usually work with, $m$ is at least $n - 1$, so moving from $O(m)$ to $O(n)$ is generally an improvement
- `areAdjacent(v1, v2)` - Check one entry, which is $O(1)$. If we only store the upper half, make sure the smaller index comes first, swapping them if needed
- `insertEdge` - Add the edge to the edge list, then store a pointer to it in the matrix, which is $O(1)$
- `removeEdge(v1, v2)` - Now we can find the edge in $O(1)$ by its endpoints and follow the pointer to remove it, so this is $O(1)$
- `insertVertex` - Every row of the matrix needs a new entry, and we need a whole new row. Even with array doubling, that's $O(n)$ (without doubling, it's $O(n^2)$, so you'll see both runtimes depending on what's assumed)
- `removeVertex` - We still have to go through `v`'s whole row and column to remove its edges, which is $O(n)$

So the matrix makes `areAdjacent` and `removeEdge` constant, but building a graph one vertex at a time is now slow, since we keep resizing the matrix. In practice, an adjacency matrix gets used for *static* sets of vertices: count the vertices, create a matrix that size once, then fill it in. There are real graphs with a fixed set of vertices but very dynamic edges, and the matrix is very effective for those. It's also really easy to write, so it gets used a lot, and the few algorithms that only ever ask `areAdjacent` are very fast with it

The other problem is *space*. If the graph is *sparse*, with $m$ on the order of $n$, we're using $O(n^2)$ space to store $O(n)$ edges. Whether that's a problem depends on whether the graph could ever fill up and whether we can afford to store the full matrix at all

Both of these get used, but there's a better choice for most graphs, which comes next

== Adjacency List

The adjacency matrix tried to speed up *everything* by indexing every possible edge. Let's be more targeted. Think about what almost every graph algorithm does: exploring a graph, looking for a path, or a traversal like the one in MP Traversals all start at a vertex, look at its neighbors, then at *their* neighbors, and so on. The way we learn the structure of a graph is by asking for the neighbors of a vertex, so the operation we really want to be fast is `incidentEdges(v)`

How fast could `incidentEdges(v)` possibly be? Just *telling* someone the edges incident on $v$ takes $deg(v)$ time: if $v$ has six incident edges, that's six things to hand back, and if it has 10,000, that's 10,000. So the best we can hope for is $O(deg(v))$, and the simplest way to get it is to store the answer. We keep the vertex vector and the edge list from before, and give every vertex a linked list of its incident edges, called its *adjacency list*

@graph-adjacency-list shows the adjacency lists for the graph from @graph-edge-list, with each edge labelled by its name. Edge $a$ connects $u$ and $v$, so it shows up in both of their lists, and $w$ has three incident edges, so its list has three entries. The lists are *doubly* linked, so we can remove any entry in $O(1)$ once we have a pointer to it. Linked lists are a solved problem, so in practice we'd just use an STL `list` (which is doubly linked) rather than writing our own

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    align: center + horizon,
    graph(example-nodes, ("u-v:a", "u-w:b", "v-w:c", "w-z:d")),
    grid(
      columns: 1,
      row-gutter: 0.8em,
      align: left,
      linked-list($a$, $b$, head: "u"),
      linked-list($a$, $c$, head: "v"),
      linked-list($b$, $c$, $d$, head: "w"),
      linked-list($d$, head: "z"),
    ),
  ),
  caption: [The graph from @graph-edge-list with its edges named (left), and the adjacency list of each vertex (right). The lists are drawn singly linked to keep them readable, but each one is really doubly linked],
) <graph-adjacency-list>

=== Connecting the Edges

The adjacency lists make `incidentEdges` fast, but we still can't *find* an edge. Vertices are numbered, so going to vertex 2 is $O(1)$, but an edge's name is its pair of endpoints, and there's nothing to index by that. So, since we love pointers, we add more of them

- Every entry in an adjacency list points to the edge it stands for in the edge list
- Every edge in the edge list points back to its two entries in the adjacency lists, one in each endpoint's list

So edge $a$ points to its entry in $u$'s list and to its entry in $v$'s list, and each of those entries points back at $a$. That's four pointers for every edge. Here's what each edge in @graph-adjacency-list stores

#table(
  columns: 3,
  table.header([*Edge*], [*Endpoints*], [*Points to*]),
  [$a$], [0, 1], [The 1st entry of $u$'s list and the 1st entry of $v$'s list],
  [$b$], [0, 2], [The 2nd entry of $u$'s list and the 1st entry of $w$'s list],
  [$c$], [1, 2], [The 2nd entry of $v$'s list and the 2nd entry of $w$'s list],
  [$d$], [2, 3], [The 3rd entry of $w$'s list and the 1st entry of $z$'s list],
)

That's a lot of pointers to keep straight, and it's exactly the kind of thing that's easy to get subtly wrong. But it's all stuff we've been doing all semester. In C++, an iterator into an STL `list` can play the role of a pointer to one of its elements

```cpp
// Graph.h

struct Edge;
using EdgeIt = std::list<Edge>::iterator; // points to an edge in the edge list

struct Edge {
    int u;
    int v;
    std::list<EdgeIt>::iterator uEntry; // this edge's entry in u's adjacency list
    std::list<EdgeIt>::iterator vEntry; // this edge's entry in v's adjacency list
    // plus any extra edge data, like a weight
};

std::vector<Vertex> vertices;       // vertex i is stored at index i
std::vector<std::list<EdgeIt>> adj; // adj[i] is the adjacency list of vertex i
std::list<Edge> edges;
```

How much space did this cost? Every edge adds two entries to adjacency lists and four pointers, which is a constant amount per edge, and every vertex adds one (possibly empty) list. So the total space is $O(n + m)$, which is as good as it gets, since that's what it takes just to store the vertices and edges at all. Unlike the adjacency matrix, space isn't a concern here

=== Inserting

- `insertVertex` - Push the vertex onto the vector along with an empty adjacency list, since a new vertex has no edges yet. That's $O(1)$
- `insertEdge(u, v)` - Add the edge to the edge list, then add an entry for it to the end of both $u$'s and $v$'s adjacency lists, and hook up the four pointers. That's a fixed amount of work no matter how big the graph is, so it's $O(1)$

```cpp
// Graph.cpp

/** Adds a vertex with no edges
 * Runtime: O(1)
 */
void insertVertex(const Vertex& data) {
    vertices.push_back(data);
    // a new vertex starts with an empty adjacency list
    adj.push_back({});
}

/** Adds an edge between u and v
 * Runtime: O(1)
 */
void insertEdge(int u, int v) {
    EdgeIt e = edges.insert(edges.end(), Edge{u, v, {}, {}});
    // add the edge to both endpoints' lists, and remember where it went in each
    e->uEntry = adj[u].insert(adj[u].end(), e);
    e->vEntry = adj[v].insert(adj[v].end(), e);
}
```

That's as good as the edge list, and better than the adjacency matrix, which had to grow a whole new row and column for every new vertex

=== Removing an Edge

If we already have the edge, removing it is like taking apart anything else built out of pointers. Before we remove the edge itself, we follow its two pointers out to its entries in its endpoints' adjacency lists and remove those, which is $O(1)$ each in a doubly linked list. Then we remove the edge from the edge list, which is also $O(1)$. So with access to the edge, `removeEdge` is $O(1)$

```cpp
// Graph.cpp

/** Removes an edge we already have
 * Runtime: O(1)
 */
void removeEdge(EdgeIt e) {
    // remove the edge's entries from both adjacency lists before the edge itself
    adj[e->u].erase(e->uEntry);
    adj[e->v].erase(e->vEntry);
    edges.erase(e);
}
```

What if all we know is the endpoints, like `removeEdge(v1, v2)`? Then we have to find the edge first: go to `v1` and walk through its adjacency list until we find the edge whose other end is `v2`, which takes $O(deg(v_1))$ in the worst case. We can do a little better. An STL `list` keeps track of its size, so we can check both degrees in $O(1)$ and search the shorter list, which finds the edge in $O(min(deg(v_1), deg(v_2)))$

In practice, we almost always have the edge already. An algorithm that wants to remove an edge has usually just been *looking at* that edge, which is how it decided to remove it. It doesn't wake up thinking "I bet there's an edge between 7 and 12, let's remove it"

=== Removing a Vertex

Going to the vertex is still $O(1)$, and we can still tombstone it just like in the edge list. But first we have to remove all of its incident edges, since every edge needs both of its endpoints in the graph. Its adjacency list tells us exactly which edges those are, so

+ For each edge in `v`'s adjacency list, remove that edge
+ Tombstone `v`

```cpp
// Graph.cpp

/** Removes vertex v and every edge incident on it
 * Runtime: O(deg(v))
 */
void removeVertex(int v) {
    // removing an edge erases it from this list, so keep removing the front one
    while (!adj[v].empty()) {
        removeEdge(adj[v].front());
    }
    // then tombstone vertex v, like in the edge list
}
```

Notice we keep removing the *front* edge instead of looping through the list with a range-based `for`, since removing an edge erases its entry from the very list we'd be looping through

Each `removeEdge` is $O(1)$, and we do it $deg(v)$ times, so `removeVertex` is $O(deg(v))$. That isn't constant, but it can't be: we *have* to remove every edge connected to `v`, and those are the only things we look at

So every operation that changes the graph is as fast as it could possibly be (other than finding an edge by its endpoints), it just takes a lot of code. That's also why we don't save graphs to disk this way: all of these pointers only exist to make changes fast, and a saved file never changes

=== Incident Edges

`incidentEdges(v)` just hands back `v`'s adjacency list. Strictly speaking, returning a reference to the list is $O(1)$ and making a copy is $O(deg(v))$, and you'll see both. Either way, we'll call it $O(deg(v))$: the reason anyone asks for the incident edges is to go through them next, which takes $O(deg(v))$ anyway, and $O(deg(v)) + O(deg(v))$ is still $O(deg(v))$

```cpp
// Graph.cpp

/** Returns the edges incident on v
 * Runtime: O(deg(v))
 */
const std::list<EdgeIt>& incidentEdges(int v) {
    return adj[v];
}
```

This is the operation we built the whole thing for, and it's exactly as fast as it can be

=== Are Adjacent

Here's where the adjacency list loses. To check whether `v1` and `v2` are adjacent

+ Go to whichever of `v1` and `v2` has the smaller degree
+ Check every edge in its adjacency list, and if one of them has the other vertex as its other end, they're adjacent
+ If none of them do, they aren't adjacent

```cpp
// Graph.cpp

/** Checks whether there's an edge between v1 and v2
 * Runtime: O(min(deg(v1), deg(v2)))
 */
bool areAdjacent(int v1, int v2) {
    // make v1 the endpoint with the shorter adjacency list
    if (adj[v1].size() > adj[v2].size()) { std::swap(v1, v2); }
    for (EdgeIt e : adj[v1]) {
        // e's other end is v2 exactly when one of its endpoints is v2
        if (e->u == v2 || e->v == v2) { return true; }
    }
    return false;
}
```

That's $O(min(deg(v_1), deg(v_2)))$, which doesn't sound bad, until we ask how big a degree can get. In a graph where everything is connected to everything, both vertices have degree $n - 1$, so `areAdjacent` is $O(n)$ in the worst case, compared to the adjacency matrix's $O(1)$

This is why the adjacency matrix still gets used. If a graph has a fixed set of vertices and lots of edges that keep appearing and disappearing, and the main thing we ask is whether two vertices are adjacent, the matrix is a big win. Think of a city traffic network, where every intersection is a vertex and an edge means the road between them is open. Accidents and construction keep closing and reopening roads, and we keep asking "can I get directly from here to there?" But most graph algorithms rarely ask `areAdjacent`. They explore, which means calling `incidentEdges` over and over

=== Why Linked Lists?

Why not store each adjacency list as a vector? We could, but removing an entry from the middle of a vector means shifting everything after it over, which is $O(deg(v))$. Then `removeEdge` would cost $O(deg(v_1) + deg(v_2))$ instead of $O(1)$, which is $O(n)$ in a well-connected graph, and `removeVertex`, which removes $deg(v)$ edges, would go from $O(deg(v))$ to $O(n^2)$ in the worst case. Worse, our edges point *into* the adjacency lists, and shifting or resizing a vector moves its entries around, so those pointers would stop working

An array is great when we want a block of data. A linked list shines when we keep jumping to arbitrary places inside it, and that's exactly what graph algorithms do. Say we're looking for a path from $u$ to $z$ in @graph-adjacency-list. From $u$, we take edge $a$ to $v$. In $v$'s list, $a$ is where we came from, so we try $c$, which takes us to $w$, and in $w$'s list, $d$ takes us to $z$. Chasing those pointers is exactly how a graph algorithm runs. That mess of pointers *is* the graph, just turned from a nice picture into data. That's also why we'll reason about graph algorithms using the nice picture and not the mess, while knowing we could code the mess and get all of these fast operations

=== The Adjacency List in Practice

The adjacency list is the gold standard general graph format, but in practice it doesn't get used as often as you might expect, because it's a lot of pointer code to get right. The C++ standard library doesn't even have a general graph, for much the same reason. Real programs usually already have their data stored in a structure that makes sense for everything else they're doing, and that data already has connections. A compiler, for example, links instructions and basic blocks to each other in exactly this way, but with structures built for its own data, not a general graph library. So instead of building a graph, we usually treat the data we already have *as* a graph

== Comparing the Implementations

These are the three classic graph implementations. There are fancier variations, and once we've seen randomized data structures, we could revisit them to make some of these operations faster. Each of the three has its place

- *Edge list* - Great for storing graphs on disk, since reading and writing it is as fast as reading and writing the file
- *Adjacency matrix* - Great when we mostly care about `areAdjacent`, and pretty good as long as the set of vertices doesn't change
- *Adjacency list* - The best choice in almost every case, with really only one weakness: `areAdjacent`

From now on, unless we say otherwise, we'll assume a graph is stored as an adjacency list

#table(
  columns: 4,
  table.header([*Operation*], [*Edge List*], [*Adjacency Matrix*], [*Adjacency List*]),
  [Space], [$O(n + m)$], [$O(n^2)$], [$O(n + m)$],
  [`insertVertex`], [$O(1)$], [$O(n)$], [$O(1)$],
  [`removeVertex`], [$O(m)$], [$O(n)$], [$O(deg(v))$],
  [`insertEdge`], [$O(1)$], [$O(1)$], [$O(1)$],
  [`removeEdge`], [$O(m)$], [$O(1)$], [$O(1)$],
  [`incidentEdges`], [$O(m)$], [$O(n)$], [$O(deg(v))$],
  [`areAdjacent`], [$O(m)$], [$O(1)$], [$O(min(deg(v_1), deg(v_2)))$],
)

The adjacency list's $O(1)$ `removeEdge` assumes we already have the edge. If we only know its endpoints, finding it first takes $O(min(deg(v_1), deg(v_2)))$
