#import "../diagrams.typ": crossing-edges, graph, tree

#let town = (A: (0, 3.0), B: (0, 0.2), C: (2.8, 3.4), D: (1.8, 1.6), E: (3.8, 1.6), F: (5.4, 0.2), G: (6.0, 2.2), H: (4.8, 3.4))
#let roads = ("A-D:2", "E-H:3", "F-G:4", "A-B:5", "B-D:6", "G-E:7", "G-H:8", "E-C:9", "C-H:10", "E-F:11", "D-E:12", "A-C:13", "B-E:14")
#let mst = ("A-D", "E-H", "F-G", "A-B", "G-E", "E-C", "D-E")

= MST: Minimum Spanning Tree (Kruskal's Algorithm)

We're finally moving into the last chunk of graphs. We've done the vocabulary, the implementations, and the traversals, so now let's look at graph algorithms that *aren't* traversals. The first one is the *minimum spanning tree*

== Why Minimum Spanning Trees?

Here's a town where every road is a dirt road. The town just got some money, and it's going to pave some of them. Paving is expensive, so every road has a cost (in millions of dollars), and the question is: what's the *cheapest* set of roads we can pave so that everybody can get from anywhere to anywhere driving only on paved roads? @mst-example shows the town as a weighted graph, with a vertex for every house and an edge for every road

#figure(
  graph(town, roads),
  caption: [Example: a town with 8 houses and 13 dirt roads. Each edge's weight is the cost (in millions) of paving that road],
) <mst-example>

This is a really useful question to be able to answer. It's the same as a networking question: which network links have to be working for me to get a message to every place on my network?

There are a couple of greedy approaches

- *Start from my house* - I live at $A$, and I'm greedy, so I start paving roads that make it easier for *me* to get places. Every time, I pave the cheapest road that reaches a house I can't drive to yet. That's $A D$ for 2, then $A B$ for 5, then $D E$ for 12 (the cheapest way out of $\{A, B, D\}$), and so on, growing a paved area outwards from my house
- *Cheapest road anywhere* - Someone less selfish ignores where they live. Every time, they pave the cheapest road *anywhere in town* that connects two places that weren't connected yet. That's $A D$ for 2, $E H$ for 3, $F G$ for 4, and so on, with little paved patches all over town that slowly join together

If we carry both of them out, they end up paving exactly the same roads, the 7 bold edges on the left of @mst-two-trees, for a total of $2 + 3 + 4 + 5 + 7 + 9 + 12 = 42$ million either way. These two strategies are the two algorithms we'll study for this problem. We didn't come up with them, of course: the first is *Prim's algorithm* (next chapter), and the second is *Kruskal's algorithm*, which is this chapter

The obvious question is how we keep track of all of this. It's easy when we're looking at a picture and pointing at roads, but in code, how do we know whether a road "connects two places that weren't connected yet"?

== The MST Problem

Formally, the *minimum spanning tree* (MST) problem takes a *connected*, *undirected*, *weighted* graph $G = (V, E)$ and returns a graph $G' = (V, E')$ such that

- $G'$ is a *spanning tree* of $G$: recall that means it includes every vertex, is connected, and has no cycles, so it has exactly $n - 1$ edges
- $G'$ has the *minimum total edge weight* among all possible spanning trees of $G$

There are usually a *lot* of spanning trees. From any spanning tree, we can remove one edge, which splits it into two pieces, and add a different edge that reconnects them. In @mst-two-trees, swapping $G E$ (7) for $G H$ (8) gives another perfectly good spanning tree, but it costs 43 instead of 42

#figure(
  grid(
    columns: 2,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: center + horizon,
    graph(town, roads, bold: mst),
    graph(town, roads, bold: ("A-D", "E-H", "F-G", "A-B", "G-H", "E-C", "D-E")),
    [The MST: total weight 42], [Another spanning tree: total weight 43],
  ),
  caption: [Two spanning trees of the town from @mst-example, shown as the bold edges. Swapping $G E$ (7) for $G H$ (8) still connects everything without a cycle, but it costs more],
) <mst-two-trees>

Notice we said *a* minimum spanning tree. If several edges have the same weight, there can be more than one spanning tree with the minimum total, and any of them is a correct answer. When every edge weight is different, like in our town, there's exactly one MST

== Kruskal's Algorithm

Kruskal's algorithm is the "cheapest road anywhere" strategy: look at the edges from *cheapest to most expensive*, and add an edge to the tree as long as it connects two pieces that weren't already connected. To actually do that, we need answers to two questions

- How do we get the edges in order from cheapest to most expensive?
- How do we know whether an edge connects two things that weren't already connected?

=== Getting the Edges in Order

What we need is a *priority queue* of edges, ordered by weight, where `removeMin` always hands us the cheapest edge we haven't looked at yet. There are two good ways to build one

- *Sort the edge list* by weight. A sorted list is a perfectly good priority queue, as long as we never `insert` anything into it, and we won't: we just keep track of where we are and move forward one edge at a time
- *Build a heap*. Recall that `buildHeap` turns an array into a heap in linear time, and then we `removeMin` the edges one at a time

We're sorting (or heaping) the *edges*, not the vertices, so these cost $O(m log m)$ and $O(m)$ to build. Building the heap looks better, since we might not have to remove every edge, but we'll come back to which one is actually better once we look at the whole running time. For the example, we'll use the sorted list, since keeping a heap up to date while also running an example by hand gets messy

=== Is the Edge Useful?

When we pull an edge $(u, v)$ out of the priority queue, we need to know whether $u$ and $v$ can already reach each other through the edges we've picked. What data structure stores whether two things belong to the same set or not? A *disjoint set*!

We keep a disjoint set of the *vertices*, where each set is one connected piece of the tree we're building. At the start, no edges have been picked, so every vertex is in a set by itself. For every edge $(u, v)$

- If `find(u) != find(v)`, then $u$ and $v$ are in different pieces, so the edge connects two things that weren't connected. We add it to the tree and `union` the two sets, since those two pieces are now one
- If `find(u) == find(v)`, then $u$ and $v$ are already connected. The edge isn't just useless, it's actively *bad*: there's already a path from $u$ to $v$ in the tree, so adding the edge would make a cycle, and then we wouldn't have a tree anymore. We skip it

This is the "really cool" algorithm we were promised back when we built disjoint sets. Each check is just two `find`s, so with smart union and path compression, it's effectively $O(1)$

=== An Example

Let's run Kruskal's algorithm on the town from @mst-example. The disjoint set uses union by size and path compression, and when two sets are the same size, the first root points at the second, like `unionBySize` does. @mst-trace lists the edges in sorted order, along with what the two `find`s return and what we do with each edge

#figure(
  table(
    columns: 5,
    align: center,
    table.header([*Edge*], [*Weight*], [*`find(u)`*], [*`find(v)`*], [*Result*]),
    [$A D$], [2], [$A$], [$D$], [Add, union],
    [$E H$], [3], [$E$], [$H$], [Add, union],
    [$F G$], [4], [$F$], [$G$], [Add, union],
    [$A B$], [5], [$D$], [$B$], [Add, union],
    [$B D$], [6], [$D$], [$D$], [Skip: cycle],
    [$G E$], [7], [$G$], [$H$], [Add, union],
    [$G H$], [8], [$H$], [$H$], [Skip: cycle],
    [$E C$], [9], [$H$], [$C$], [Add, union],
    [$C H$], [10], [$H$], [$H$], [Skip: cycle],
    [$E F$], [11], [$H$], [$H$], [Skip: cycle],
    [$D E$], [12], [$D$], [$H$], [Add, union: done],
    [$A C$], [13], [], [], [Never looked at],
    [$B E$], [14], [], [], [Never looked at],
  ),
  caption: [Kruskal's algorithm on the town from @mst-example, one edge at a time in order of weight],
) <mst-trace>

The first three edges are easy. `find(A)` returns $A$ and `find(D)` returns $D$, so they're in different sets: we add $A D$ to the tree and union $A$ and $D$, which points $A$ at $D$. The same thing happens for $E H$ and $F G$. Now we have three little paved patches, which you can see at the top of @mst-kruskal-first

Next is $A B$. `find(A)` now returns $D$, and `find(B)` returns $B$, so that's still fine: we add the edge and union. $D$'s set is bigger, so $B$ ends up pointing at $D$ too (with union by size, height, or rank, we'd get the same thing here)

Then we get to $B D$, which is really cheap. But `find(B)` returns $D$, and `find(D)` returns $D$. Look at the bottom of @mst-kruskal-first: we can already get from $B$ to $D$ through $A$, so $B D$ would close the cycle $B$, $A$, $D$. We skip it, which is shown with a dashed edge

#figure(
  grid(
    columns: 2,
    column-gutter: 2.5em,
    row-gutter: 1.2em,
    align: center + horizon,
    graph(town, roads, bold: ("A-D", "E-H", "F-G")),
    grid(
      columns: 5,
      column-gutter: 1em,
      align: top,
      tree(("D", "A")), tree(("H", "E")), tree(("G", "F")), tree(("B",)), tree(("C",)),
    ),
    graph(town, roads, bold: ("A-D", "E-H", "F-G", "A-B"), dashed: ("B-D",)),
    grid(
      columns: 4,
      column-gutter: 1em,
      align: top,
      tree(("D", "A", "B")), tree(("H", "E")), tree(("G", "F")), tree(("C",)),
    ),
  ),
  caption: [Kruskal's algorithm after $A D$, $E H$, and $F G$ (top), then after adding $A B$ and skipping $B D$ (bottom). The bold edges are in the tree, the dashed edge was skipped, and the uptrees on the right are the disjoint set],
) <mst-kruskal-first>

Next, $G E$: `find(G)` returns $G$ and `find(E)` returns $H$, so we add it. Both sets have 2 vertices, so $G$ points at $H$. That makes $G H$ a cycle, since `find(G)` and `find(H)` both return $H$, so we skip it

$E C$ is fine (`find(C)` is just $C$), and $C$ joins $H$'s set. But then $C H$ and $E F$ are both cycles: everything on the right side of town is already connected. Notice what path compression does during `find(F)`: $F$ points at $G$, which points at $H$, so on the way back, $F$ gets updated to point straight at $H$. You can see $F$ move in @mst-kruskal-middle

#figure(
  grid(
    columns: 2,
    column-gutter: 2.5em,
    row-gutter: 1.2em,
    align: center + horizon,
    graph(town, roads, bold: ("A-D", "E-H", "F-G", "A-B", "G-E"), dashed: ("B-D", "G-H")),
    grid(
      columns: 3,
      column-gutter: 1em,
      align: top,
      tree(("D", "A", "B")), tree(("H", "E", ("G", "F"))), tree(("C",)),
    ),
    graph(town, roads, bold: ("A-D", "E-H", "F-G", "A-B", "G-E", "E-C"), dashed: ("B-D", "G-H", "C-H", "E-F")),
    grid(
      columns: 2,
      column-gutter: 1em,
      align: top,
      tree(("D", "A", "B")), tree(("H", "E", "G", "C", "F"), highlight: ("F",)),
    ),
  ),
  caption: [Kruskal's algorithm after adding $G E$ and skipping $G H$ (top), then after adding $E C$ and skipping $C H$ and $E F$ (bottom). Path compression during `find(F)` moved $F$ (highlighted) to point straight at the root, $H$],
) <mst-kruskal-middle>

Finally, $D E$: `find(D)` returns $D$ and `find(E)` returns $H$, so we add it, and $D$'s set (3 vertices) gets pointed at $H$'s (5 vertices). Now every vertex is in one set, and we have the minimum spanning tree in @mst-kruskal-done. We never even had to look at $A C$ or $B E$

#figure(
  grid(
    columns: 2,
    column-gutter: 2.5em,
    align: center + horizon,
    graph(town, roads, bold: mst, dashed: ("B-D", "G-H", "C-H", "E-F")),
    tree(("H", "E", "G", "C", "F", ("D", "A", "B"))),
  ),
  caption: [After adding $D E$, the 7 bold edges are the MST, with total weight 42. Every vertex is now in one set, rooted at $H$],
) <mst-kruskal-done>

=== When Are We Done?

We could just keep going until the priority queue is empty, since every remaining edge would be skipped anyway. But it's clearly better to stop as soon as the tree is finished. There are a few ways to notice that

- *Everything is in the same set*. We could call `find` on every vertex and check they all return the same root, but that's $O(n)$ every time we check
- *The set is as big as the graph*. If we union by size, the root already stores the size of its set, so after each `union`, we can check whether the new set has all $n$ vertices
- *Count the edges*. A spanning tree always has exactly $n - 1$ edges, so we keep a counter of how many edges we've added, and stop when it reaches $n - 1$

The last one is the simplest, and it's what our code will do

All of this works because of data structures we already have, and the disjoint set in particular is super fast. Honestly, that's why Kruskal's algorithm is considered efficient and is used so often: without the disjoint set, keeping track of which vertices are already connected would be really hard, and nobody would use it. The disjoint set is what fundamentally enables this algorithm

== The Algorithm

Given a connected, undirected, weighted graph with $n$ vertices and $m$ edges

+ Make a disjoint set with every vertex in its own set
+ Put every edge into a priority queue ordered by weight, either by sorting the edge list or with `buildHeap`
+ Start the tree $T$ with all $n$ vertices and no edges
+ While $T$ has fewer than $n - 1$ edges, remove the cheapest edge $(u, v)$ from the priority queue
+ If `find(u) != find(v)`, add $(u, v)$ to $T$ and `union` the two sets. Otherwise, adding it would make a cycle, so skip it
+ Return $T$

== The Code

We'll use the `DisjointSets` from the disjoint sets chapter, with `find` doing path compression and `unionBySize` taking two roots. Each edge stores its two endpoints (as vertex numbers $0$ to $n - 1$) and its weight, and we return the edges of the tree

```cpp
struct Edge {
    int u;
    int v;
    int weight;
};

/** Builds a minimum spanning tree from the cheapest edges that skip cycles
 * Runtime: O(m log m)
 */
std::vector<Edge> kruskal(size_t n, std::vector<Edge> edges) {
    DisjointSets forest;
    forest.addElements(n);

    // a sorted list is a priority queue, as long as we never insert
    std::sort(edges.begin(), edges.end(), [](const Edge& a, const Edge& b) {
        return a.weight < b.weight;
    });

    std::vector<Edge> tree;
    size_t next = 0;

    // stop once the tree has n - 1 edges or we run out of edges
    while(tree.size() < n - 1 && next < edges.size()) {
        Edge e = edges[next++];
        int ru = forest.find(e.u);
        int rv = forest.find(e.v);

        // different roots: the edge joins two trees, so it can't make a cycle
        if(ru != rv) {
            tree.push_back(e);
            forest.unionBySize(ru, rv);
        }
    }
    return tree;
}
```

`next` is the "current top" of our sorted priority queue: removing the minimum just moves it forward one edge. The `next < edges.size()` check only matters if the graph isn't connected, in which case we run out of edges before we ever get $n - 1$ of them

To use a heap instead, we swap the sort for a `std::priority_queue`. It's a max-heap by default, so we give it a comparison that puts the *lightest* edge on top. Building it from the whole vector at once runs `buildHeap` (`std::make_heap`), which is $O(m)$

```cpp
struct HeavierThan {
    // max-heap by default, so heavier edges count as smaller (lightest on top)
    bool operator()(const Edge& a, const Edge& b) const {
        return a.weight > b.weight;
    }
};

using EdgeHeap = std::priority_queue<Edge, std::vector<Edge>, HeavierThan>;

// building from the whole vector at once runs buildHeap in O(m)
EdgeHeap pq(HeavierThan(), std::move(edges));
```

Then, instead of `edges[next++]`, each step of the loop takes `pq.top()` and calls `pq.pop()`, and the loop stops when `pq` is empty

== Running Time

Let's go through the algorithm one piece at a time

- *Making the disjoint set* - We put $n$ things into the disjoint set, so we have to touch $n$ things in memory no matter what: $O(n)$
- *Building the priority queue* - This depends on our choice. `buildHeap` (heapify down, starting from the last non-leaf and working back to the root) is $O(m)$, and sorting is $O(m log m)$. Remember, these are *edges*, so it's $m$, not $n$
- *Making $T$* - A graph with $n$ vertices and no edges is $O(n)$
- *Each `find` and `union`* - Technically this is $O(alpha(m, n))$, the inverse Ackermann function, but we'll just call it constant because it makes our lives easier
- *Each `removeMin`* - Also depends on our choice. In a heap, we swap the last element to the root and heapify down, which is $O(log m)$. In the sorted list, we just move `next` forward, which is $O(1)$

=== How Many Times Does the Loop Run?

It's tempting to say $n - 1$ times, since we stop as soon as the tree has $n - 1$ edges. If that were true, we'd get

- *Sorted list*: $O(m log m + n)$
- *Heap*: $O(m + n log m)$

and the heap would clearly win. But that's not what's happening: not every trip through the loop adds an edge. If we always got to add the $n - 1$ cheapest edges, that would be awesome, but there might be one vertex whose only road is the most expensive road in town, and then we have to look at *every other edge* before we can connect it. So the loop runs $O(m)$ times, and the totals are

- *Sorted list*: $O(m log m)$ to build, plus $m$ removals at $O(1)$ each, for $O(m log m + m) = O(m log m)$
- *Heap*: $O(m)$ to build, plus $m$ removals at $O(log m)$ each, for $O(m + m log m) = O(m log m)$

They're the same! The $O(n)$ parts don't matter, since a connected graph has $m >= n - 1$ edges

#table(
  columns: 3,
  table.header([*Step*], [*Sorted list*], [*Heap*]),
  [Make the disjoint set], [$O(n)$], [$O(n)$],
  [Build the priority queue], [$O(m log m)$], [$O(m)$],
  [Make $T$ with no edges], [$O(n)$], [$O(n)$],
  [$O(m)$ `removeMin`s], [$O(1)$ each], [$O(log m)$ each],
  [$O(m)$ `find`s and `union`s], [$O(alpha(m, n))$ each], [$O(alpha(m, n))$ each],
  [*Total*], [$O(m log m)$], [$O(m log m)$],
)

=== In Terms of $n$

What's the worst case for $m$? In a simple graph, $m$ is at most $(n(n - 1)) / 2$, so $m = O(n^2)$. Replacing every $m$ with $n^2$, the sorted list is $O(n^2 log n^2 + n^2)$ and the heap is $O(n^2 + n^2 log n^2)$, and since $log n^2 = 2 log n$, both are $O(n^2 log n)$ for a *dense* graph

More generally, $log m <= log n^2 = 2 log n$, so $O(m log m)$ is the same as $O(m log n)$, which is how Kruskal's algorithm is usually written. For a *sparse* graph, where $m$ is about $n$, that's $O(n log n)$

== Sorted List or Heap?

The running times are the same, so which should we use? A more precise answer is that the heap is better when we only have to *examine* a small number of edges, and it doesn't matter when we have to examine most of them

If we're going to run the algorithm once, return the tree, and keep nothing else around, a heap is a fine choice. It's never worse, and sometimes it's a little better: we're hoping we won't have to remove every edge, and that's fairly likely. In fact, the *denser* the graph gets, the less likely it is that we have to wait for the very last edge to connect everything, since for that to happen, there can't be any other edge to that vertex. Plus, we already have heap code everywhere, so it isn't any harder to write

So why would we ever pick the sorted list? A heap gets *destroyed* as we use it, since every `removeMin` takes an edge out. A sorted list doesn't change at all: our priority queue is just a position in the list, and we move it along. So if we're going to do a lot of things with this graph, a list of the edges sorted by weight is a really useful thing to keep around, and we can use it again and again

That's a real design decision

- If we're writing Kruskal's algorithm as a *library*, separate from the rest of the program, we'd probably use a heap
- If we're building a *whole program* that analyzes one big graph, like loading a million-vertex social network graph and running all sorts of analyses and visualizations on it, we might just store the graph's edges in sorted order all the time. We aren't changing the edges, just analyzing them, so the sort only has to happen once

This is where we, as programmers, can do much better than something that can't step back and look at the bigger picture. Graph algorithms aren't particularly fast, and the graphs we want to analyze can be huge, so getting the answer in three hours instead of nine actually matters. These design opportunities are where we can really use our deeper understanding of the data structures to make a difference

== The Partition Property

Why does the "start from my house" strategy work? Being greedy and always paving the cheapest road out of the paved area doesn't sound like it should give the best answer overall. The reason is the *partition property*

Split the vertices of a connected graph into two pieces, $U$ and $V - U$. Some set of edges *crosses* the partition, with one endpoint on each side. It might be one edge or many, but since the graph is connected, it's at least one. The partition property says that the *minimum weight edge crossing the partition* must be part of *some* minimum spanning tree

In @mst-partition, $U = \{A, B, D\}$, and three edges cross the partition: $D E$ (12), $A C$ (13), and $B E$ (14). The cheapest one, $D E$, is in the MST

#figure(
  graph(town, roads, highlight: ("A", "B", "D"), bold: ("D-E",), dashed: crossing-edges(roads, ("A", "B", "D")).filter(e => e != "D-E")),
  caption: [Example: partitioning the town into $U = \{A, B, D\}$ (highlighted) and everything else. Three edges cross the partition, and the cheapest one, $D E$ (bold), must be in some MST. The other two are dashed],
) <mst-partition>

It's fairly easy to see why. Every spanning tree has to include at least one of the crossing edges, since otherwise nothing in $U$ could reach anything outside it. If a spanning tree doesn't use the cheapest crossing edge, adding it makes a cycle. That cycle crosses the partition, so it has to cross back through some other crossing edge, which is at least as expensive. Removing that edge breaks the cycle and leaves a spanning tree that costs no more. Going from "must be part of *some* MST" to "must be part of the MST this algorithm builds" takes a bit more work as a proof

That's what makes the greedy strategy legal. If $U$ is the set of houses we can already reach, then the cheapest road leaving $U$ is the minimum edge crossing a partition, so every road we pave is one that belongs in a minimum spanning tree. We start from some vertex, add the cheapest edge leaving it, and keep going
