#import "../diagrams.typ": crossing-edges, graph

#let prim-nodes = (a: (0, 1.6), b: (1.8, 3.2), c: (3.6, 3.2), d: (1.8, 1.6), e: (3.6, 1.6), f: (1.8, 0), g: (3.6, 0), h: (5.4, 1.6))
#let prim-edges = ("a-b:12", "a-d:3", "a-f:14", "b-c:15", "b-d:5", "c-d:10", "c-e:7", "c-h:1", "d-e:4", "d-f:11", "e-f:13", "e-g:6", "e-h:9", "f-g:2", "g-h:8")
#let prim-step(inside, tree) = graph(
  prim-nodes,
  prim-edges,
  highlight: inside,
  bold: tree,
  dashed: crossing-edges(prim-edges, inside),
)

= MST: Minimum Spanning Tree (Prim's Algorithm)

In the previous chapter, we built a minimum spanning tree with Kruskal's algorithm, which looks at the edges from cheapest to most expensive and keeps every edge that doesn't make a cycle. Along the way it grows a whole *forest* of little trees that slowly merge into one. Prim's algorithm takes a different approach: it grows *one* tree, starting from a single vertex, and adds one vertex to it at a time

Both algorithms rely on the same fact, the *partition property* from the end of the previous chapter (@mst-partition): if we split the vertices of a graph into two groups, the minimum weight edge crossing between the two groups is part of some minimum spanning tree. Kruskal's uses it indirectly, but Prim's is basically the partition property turned directly into an algorithm

== The Idea: Grow One Side of the Partition

We pick a starting vertex, say $a$, and partition the graph into $\{a\}$ and everything else. That's a great place to start, since the minimum spanning tree of just $\{a\}$ is easy: it's $a$ with no edges

Now we look at every edge crossing the partition and add the cheapest one. By the partition property, that edge must be part of some minimum spanning tree. Its far endpoint joins our side, so we *repartition* the graph, look at the edges crossing the new boundary, add the cheapest one, and keep going until every vertex is on our side

@prim-example is the weighted graph we'll use for the rest of this chapter. It has 8 vertices and 15 edges, all with different weights

#figure(
  graph(prim-nodes, prim-edges),
  caption: [Example: the weighted graph we'll find a minimum spanning tree of, starting from $a$],
) <prim-example>

@prim-first-cut shows the first two partitions. In each one, the highlighted vertices are the tree we've grown so far, the bold edges are the edges in that tree, and the dashed edges are the ones crossing the partition. At the start, the crossing edges are $(a, d)$, $(a, b)$, and $(a, f)$, with weights 3, 12, and 14, so we add $(a, d)$. Then $d$ joins our side, and suddenly there are six crossing edges: 4, 5, 10, 11, 12, and 14

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: center + horizon,
    prim-step(("a",), ()),
    prim-step(("a", "d"), ("a-d",)),
    [Start: the tree is just $a$],
    [Add the cheapest crossing edge, $(a, d)$],
  ),
  caption: [The first two partitions of @prim-example. Highlighted vertices are in the tree, bold edges are tree edges, and dashed edges cross the partition],
) <prim-first-cut>

=== Why It's Correct

Every time we add an edge, we're adding the cheapest edge crossing *some* partition of the graph, and the partition property says that edge belongs in a minimum spanning tree. All of the edges we picked earlier live entirely inside our side of the partition, so none of them cross it, and the new edge never conflicts with them. So by induction, after every step, the edges we have are part of some minimum spanning tree, and after $n - 1$ edges, they *are* one

What about ties? If two crossing edges have the same weight, it doesn't matter which one we take: both are part of *some* minimum spanning tree. We might end up with a different tree than someone who broke the tie the other way, but both trees have the same total weight. That's the reason for the word "some": a graph with repeated weights can have more than one minimum spanning tree

== Running Prim's by Hand

@prim-steps continues from @prim-first-cut, adding one vertex at a time. Each panel shows the tree right after the new edge is added, with the edges that now cross the partition dashed

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: center + horizon,
    prim-step(("a", "d", "e"), ("a-d", "d-e")),
    prim-step(("a", "b", "d", "e"), ("a-d", "d-e", "b-d")),
    [Add $(d, e)$ with weight 4],
    [Add $(b, d)$ with weight 5],
    prim-step(("a", "b", "d", "e", "g"), ("a-d", "d-e", "b-d", "e-g")),
    prim-step(("a", "b", "d", "e", "f", "g"), ("a-d", "d-e", "b-d", "e-g", "f-g")),
    [Add $(e, g)$ with weight 6],
    [Add $(f, g)$ with weight 2],
    prim-step(("a", "b", "c", "d", "e", "f", "g"), ("a-d", "d-e", "b-d", "e-g", "f-g", "c-e")),
    prim-step(("a", "b", "c", "d", "e", "f", "g", "h"), ("a-d", "d-e", "b-d", "e-g", "f-g", "c-e", "c-h")),
    [Add $(c, e)$ with weight 7],
    [Add $(c, h)$ with weight 1: done],
  ),
  caption: [Prim's algorithm on @prim-example, continuing from @prim-first-cut. The last panel is the minimum spanning tree, with total weight 28],
) <prim-steps>

Step by step, the crossing edges and the edge we pick are

+ $\{a, d\}$: crossing 4, 5, 10, 11, 12, 14. Add $(d, e)$ with weight 4
+ $\{a, d, e\}$: crossing 5, 6, 7, 9, 10, 11, 12, 13, 14. Add $(b, d)$ with weight 5
+ $\{a, b, d, e\}$: crossing 6, 7, 9, 10, 11, 13, 14, 15. Add $(e, g)$ with weight 6
+ $\{a, b, d, e, g\}$: crossing 2, 7, 8, 9, 10, 11, 13, 14, 15. Add $(f, g)$ with weight 2
+ $\{a, b, d, e, f, g\}$: crossing 7, 8, 9, 10, 15. Add $(c, e)$ with weight 7
+ $\{a, b, c, d, e, f, g\}$: crossing 1, 8, 9. Add $(c, h)$ with weight 1

The final tree is $(a, d)$, $(d, e)$, $(b, d)$, $(e, g)$, $(f, g)$, $(c, e)$, and $(c, h)$, with total weight $3 + 4 + 5 + 6 + 2 + 7 + 1 = 28$. Since every weight in @prim-example is different, this is the *only* minimum spanning tree, so Kruskal's algorithm finds exactly the same tree. It just adds the edges in a different order: Kruskal's takes $(c, h)$ first and $(f, g)$ second, while Prim's can't take either one until the tree reaches them. Notice how Prim's adds 2 after 6 and ends with 1: it doesn't add edges in sorted order, it only ever picks the cheapest edge that touches the tree

=== Only the Cheapest Edge to Each Vertex Matters

Running this on paper is pretty easy: you just walk along the boundary and look at what crosses it. But it's not at all clear how a program keeps track of this, since every time we repartition the graph, some edges stop crossing and new ones start

The key observation is that for any vertex outside the tree, the cheapest crossing edge *to that vertex* only ever goes down. The tree only grows, so an edge from the tree to $v$ keeps crossing the partition until $v$ itself joins the tree, and then it never crosses again. In the meantime, new edges to $v$ can show up as their other endpoints join the tree, and each one can only make $v$'s cheapest option cheaper

Look at $h$ in @prim-steps. At first there's no edge from the tree to $h$ at all, so its cost is $infinity$. When $e$ joins, the edge $(e, h)$ gives it a cost of 9. When $g$ joins, $(g, h)$ drops it to 8. When $c$ joins, $(c, h)$ drops it to 1, and now it's the cheapest crossing edge in the whole graph, so we pick it. Every vertex follows the same pattern: it starts at $infinity$ (or with some edge from the start vertex), its cost goes down over time, and then it's chosen

That means we never care about a more expensive edge to the same vertex. Once we've seen the edge of weight 8 into $h$, the edge of weight 9 will *never* be part of the spanning tree, so we can just forget about it. Instead of tracking every crossing edge, each vertex $v$ outside the tree only needs to remember two things

- $d[v]$, the weight of the cheapest edge from the tree to $v$ that we know of (or $infinity$ if there isn't one yet)
- $p[v]$, the *predecessor* of $v$: the tree vertex on the other end of that edge. The edge is defined by where we came from and where we are, so $(p[v], v)$ is the edge we'd add to reach $v$

Then picking the next edge is just picking the vertex outside the tree with the smallest $d[v]$. @prim-table shows these values after each vertex joins the tree

#figure(
  table(
    columns: 9,
    align: center + horizon,
    table.header([*Add*], [$a$], [$b$], [$c$], [$d$], [$e$], [$f$], [$g$], [$h$]),
    [Start], [*0*], [$infinity$], [$infinity$], [$infinity$], [$infinity$], [$infinity$], [$infinity$], [$infinity$],
    [$a$], table.cell(fill: luma(235))[], [12 ($a$)], [$infinity$], [*3 ($a$)*], [$infinity$], [14 ($a$)], [$infinity$], [$infinity$],
    [$d$], table.cell(fill: luma(235))[], [5 ($d$)], [10 ($d$)], table.cell(fill: luma(235))[], [*4 ($d$)*], [11 ($d$)], [$infinity$], [$infinity$],
    [$e$], table.cell(fill: luma(235))[], [*5 ($d$)*], [7 ($e$)], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], [11 ($d$)], [6 ($e$)], [9 ($e$)],
    [$b$], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], [7 ($e$)], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], [11 ($d$)], [*6 ($e$)*], [9 ($e$)],
    [$g$], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], [7 ($e$)], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], [*2 ($g$)*], table.cell(fill: luma(235))[], [8 ($g$)],
    [$f$], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], [*7 ($e$)*], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], [8 ($g$)],
    [$c$], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], table.cell(fill: luma(235))[], [*1 ($c$)*],
  ),
  caption: [The cost $d[v]$ and predecessor $p[v]$ of every vertex after each vertex joins the tree in @prim-steps. Shaded vertices are already in the tree, and the bold entry is the smallest cost outside the tree, which is the vertex that joins next],
) <prim-table>

Reading down a column of @prim-table shows the "only goes down" pattern: $f$ goes from 14 to 11 to 2, $c$ goes from $infinity$ to 10 to 7, and $h$ goes from $infinity$ to 9 to 8 to 1

== The Algorithm

To find a minimum spanning tree of a connected graph starting from a vertex $s$

+ Set every vertex's cost $d[v]$ to $infinity$ and its predecessor $p[v]$ to nothing, since we don't know how to get anywhere yet. Then set $d[s] = 0$: we start at $s$, so we didn't come from anywhere
+ Put *every* vertex into a min priority queue, ordered by its cost $d[v]$
+ Repeat $n$ times: remove the vertex $m$ with the smallest cost from the priority queue and add it to the tree (along with the edge $(p[m], m)$, unless $m$ is $s$)
+ For each neighbor $v$ of $m$ that isn't in the tree yet, if the edge $(m, v)$ is cheaper than $d[v]$, we've found a better way to reach $v$: set $d[v]$ to the weight of $(m, v)$, set $p[v] = m$, and *update $v$'s position in the priority queue*
+ When the priority queue is empty, the edges $(p[v], v)$ for every $v != s$ are a minimum spanning tree

== The Code

Here, the graph is stored as an adjacency list, where `g[m]` holds the incident edges of vertex `m`, and each edge stores the vertex on its other end and its weight. Instead of building a separate graph for the tree, we just mark which vertices are in it, and return the predecessors, which describe every tree edge

```cpp
struct Edge {
    int to;
    int weight;
};

using Graph = std::vector<std::vector<Edge>>; // g[v] holds v's incident edges

/** Builds a minimum spanning tree from `s` and returns each vertex's parent
 * Runtime: O(m log n)
 */
std::vector<int> prim(const Graph& g, int s) {
    int n = g.size();
    std::vector<int> d(n, INT_MAX); // INT_MAX stands in for infinity
    std::vector<int> p(n, -1);      // -1 means no predecessor
    std::vector<bool> inTree(n, false);
    d[s] = 0;

    VertexHeap q(d); // buildHeap on all n vertices, ordered by d
    for(int i = 0; i < n; i++) {
        // the cheapest vertex left is the next one added to the tree
        int m = q.removeMin();
        inTree[m] = true;
        for(const Edge& e : g[m]) {
            int v = e.to;
            // found a cheaper edge connecting `v` to the tree
            if(!inTree[v] && e.weight < d[v]) {
                d[v] = e.weight;
                p[v] = m;
                q.decreaseKey(v, d[v]);
            }
        }
    }
    return p;
}
```

If this looks familiar, it should: it's almost exactly breadth-first search. The one really important change is that where BFS used a *queue*, Prim's uses a *priority queue*. Notice the priority queue holds *vertices*, not edges like the one in Kruskal's, and that every vertex goes in at the start. So instead of adding neighbors to the queue, we *update* the neighbors that are already there

=== Updating the Priority Queue

The subtle part is `d[v] = e.weight`. It looks like a constant time assignment to an array, but the priority queue is ordered by $d$, so whenever a cost changes, $v$ might be in the wrong place in the queue. For the code to be correct, that line also has to reorder the priority queue, which is why we call `decreaseKey` right after it. This is very different from Kruskal's priority queue, which is ordered by edge weights that never change

How expensive is that? If the priority queue is a *sorted* array, $v$ might have to move all the way to the front, shifting everything in between, so each update is $O(n)$

With a heap, we can do much better. If a key in a heap suddenly has the wrong priority, we can fix it, and here we have a big advantage: the only way a priority ever changes is by getting *smaller*. A smaller key can only be out of place relative to its parent, never its children, so all we have to do is *heapify up* from that node, which is $O(log n)$ since the heap holds at most $n$ vertices

There's one catch the code hides: to heapify up from $v$, we need to know *where* $v$ is in the heap. Searching the heap for it would be $O(n)$, which defeats the point. So the heap also keeps an array `pos_`, where `pos_[v]` is $v$'s index in the heap, and every swap updates it

```cpp
// VertexHeap.cpp

/** Lowers the cost of `v` and heapifies it up to its new place
 * Runtime: O(log n)
 */
void VertexHeap::decreaseKey(int v, int newCost) {
    cost_[v] = newCost;

    // a smaller cost can only be out of place relative to its parent
    _heapifyUp(pos_[v]);
}

/** Swaps the vertex at `index` up until its parent's cost is no larger
 * Runtime: O(log n)
 */
void VertexHeap::_heapifyUp(size_t index) {
    if(index > 1) {
        size_t parent = _parent(index);
        if(cost_[heap_[index]] < cost_[heap_[parent]]) {
            _swap(index, parent);
            _heapifyUp(parent);
        }
    }
}

/** Swaps two heap slots and updates `pos_` for both vertices
 * Runtime: O(1)
 */
void VertexHeap::_swap(size_t i, size_t j) {
    std::swap(heap_[i], heap_[j]);
    pos_[heap_[i]] = i; // keep track of where each vertex moved
    pos_[heap_[j]] = j;
}
```

This is the same `_heapifyUp` from the heaps chapter, except the heap stores vertex numbers, compares them by their costs, and swaps through `_swap` so `pos_` always stays correct. `removeMin` and `_heapifyDown` use `_swap` the same way

== Running Time

Let's break `prim` into pieces and see how each one depends on how we store the priority queue and the graph

+ *Initialization* - Setting up `d`, `p`, and `inTree` touches every vertex once, which is $O(n)$
+ *Building the priority queue* - With a heap, `buildHeap` is $O(n)$. With a sorted array, we'd have to sort, which is $O(n log n)$. With an unsorted array, we just copy the vertices in, which is $O(n)$
+ *Removing the minimum* - This happens exactly $n$ times. Each `removeMin` is $O(log n)$ with a heap, so that's $O(n log n)$. With an unsorted array, we have to look through the whole array for the smallest cost, which is $O(n)$ each and $O(n^2)$ total
+ *Looping over the neighbors* - Over the whole algorithm, we take every vertex out of the queue once and look at all of its neighbors, which is $sum_(v in V) deg(v) = 2m$ neighbor checks. The question is how long it takes to *find* the neighbors
+ *Updating a cost* - This can happen at most once per neighbor check, so $O(m)$ times. Each update is $O(log n)$ with a heap, $O(n)$ with a sorted array, and $O(1)$ with an unsorted array, where we just change the cost and leave the vertex where it is

=== Adjacency List vs. Adjacency Matrix

The neighbor loop is where the graph implementation matters. With an *adjacency list*, `incidentEdges(m)` takes $O(deg(m))$, which is exactly as much time as the loop body runs anyway. So we can *charge* the cost of finding each neighbor to the work we do on that neighbor, and finding all of them over the whole algorithm only adds $O(m)$

With an *adjacency matrix*, finding the neighbors of $m$ means checking its whole row, which takes $O(n)$ no matter how many neighbors $m$ actually has. We do that for all $n$ vertices, so that's $O(n^2)$. Notice this doesn't change how many times the loop body runs (still once per neighbor), only how long it takes to get to it

Adding up the pieces for each combination (the initialization and building the queue never dominate)

- *Heap and adjacency list* - $O(n log n)$ to remove, $O(m)$ to find neighbors, and $O(m log n)$ to update, so $O(n log n + m log n)$
- *Heap and adjacency matrix* - $O(n log n)$ to remove, $O(n^2)$ to find neighbors, and $O(m log n)$ to update, so $O(n^2 + m log n)$
- *Unsorted array and either graph* - $O(n^2)$ to remove, at most $O(n^2)$ to find neighbors, and only $O(m) = O(n^2)$ to update, since updating is free, so $O(n^2)$

#table(
  columns: 3,
  table.header([*Priority queue*], [*Adjacency matrix*], [*Adjacency list*]),
  [Binary heap], [$O(n^2 + m log n)$], [$O(n log n + m log n)$],
  [Unsorted array], [$O(n^2)$], [$O(n^2)$],
)

There's a reason we picked an *unsorted* array here, even though a sorted array seems like the natural priority queue. A sorted array makes `removeMin` cheap, but every update costs $O(n)$, and we might do $O(m)$ of them, which is $O(n m)$, or $O(n^3)$ for a graph with $m approx n^2$ edges. Since Prim's updates far more often than it removes, cheap updates win

The graph is connected, so $m >= n - 1$, which means $n log n$ is never bigger than $m log n$. So with a heap and an adjacency list, we can simplify the runtime to just $O(m log n)$

=== Sparse vs. Dense Graphs

The number of edges in a connected graph can be anywhere from $n - 1$ to about $n^2$. A *sparse* graph has very few edges, $m approx n$, and a *dense* graph has close to the most edges possible, $m approx n^2$. Plugging those in

#table(
  columns: 3,
  table.header([*Implementation*], [*Sparse ($m approx n$)*], [*Dense ($m approx n^2$)*]),
  [Heap and adjacency list], [$O(n log n)$], [$O(n^2 log n)$],
  [Heap and adjacency matrix], [$O(n^2)$], [$O(n^2 log n)$],
  [Unsorted array (either graph)], [$O(n^2)$], [$O(n^2)$],
)

So which one is best depends on how dense the graph is. On a sparse graph, the heap and adjacency list win by a lot. On a dense graph, the unsorted array wins, because we might update a cost almost every time we look at an edge, and with a heap, every one of those updates costs $O(log n)$

Notice that on a dense graph, the adjacency matrix stops mattering. The only problem with the matrix is that finding the neighbors of $v$ takes $O(n)$ instead of $O(deg(v))$. But if $m approx n^2$, then $deg(v)$ is close to $n$ anyway. If a graph has a huge number of edges, checking every *possible* edge costs about the same as checking every *real* edge, so the matrix is fine. It's only when there are few edges that checking every real edge is much faster than checking every possible one

=== Fibonacci Heaps

If you look up Prim's algorithm on Wikipedia, you'll see a different bound: $O(m + n log n)$. That comes from a different heap, the *Fibonacci heap*, invented by Fredman and Tarjan in 1984. We won't cover how it works: it's complicated to code, and it has bad enough constant factors that it doesn't really help until the graph is very large. What matters is that it's a priority queue with a special operation, *decrease key*, which increases a key's priority (makes it smaller, in our case) in amortized $O(1)$ time, while `removeMin` is still amortized $O(log n)$

With a Fibonacci heap and an adjacency list, every update becomes constant time, so the $O(m log n)$ updates turn into $O(m)$, and the total is $O(n log n + m)$. That's the bound Wikipedia gives, and it assumes both a Fibonacci heap and an adjacency list

Why can't we get rid of the $n log n$ too? It comes from calling `removeMin` $n$ times, and the best heaps we know still take $O(log n)$ per `removeMin`. That isn't just a gap in our knowledge. Prim's builds a priority queue of $n$ vertices and then takes them all out in sorted order, so if a priority queue that only compares keys could do that in less than $O(n log n)$ total, we could use it to sort $n$ values faster than $O(n log n)$, which is impossible for a comparison sort

== Prim's vs. Kruskal's

Kruskal's algorithm runs in $O(n + m log m)$, since its priority queue holds edges. So why do people usually write it as $O(m log n)$? Because $m$ isn't an arbitrary number: in a simple graph, it's at most about $n^2$. So for some constant $c$, $m <= c n^2$, and

$ log m <= log(c n^2) = log c + 2 log n $

The constant $log c$ and the factor of 2 fall out under big O, so $O(log m)$ and $O(log n)$ are the same thing, and $O(m log m) = O(m log n)$. We can also drop the $n$: Kruskal's only produces a spanning tree if the graph is connected, so $m >= n - 1$, and $n$ is smaller than $m log n$. You'll see it written both with and without the $n$

#table(
  columns: 3,
  table.header([*Algorithm*], [*Sparse ($m approx n$)*], [*Dense ($m approx n^2$)*]),
  [Kruskal's: $O(m log n)$], [$O(n log n)$], [$O(n^2 log n)$],
  [Prim's, binary heap: $O(n log n + m log n)$], [$O(n log n)$], [$O(n^2 log n)$],
  [Prim's, Fibonacci heap: $O(n log n + m)$], [$O(n log n)$], [$O(n^2)$],
)

Prim's bound has an extra $n log n$ term, so it looks like it should be worse, but on both sparse and dense graphs, Kruskal's and Prim's with a binary heap come out *exactly the same*. A Fibonacci heap doesn't help on a sparse graph either. It only pulls ahead on dense graphs, and there, the unsorted array version of Prim's already gets $O(n^2)$ without any fancy heap

So which should you choose? There isn't really a right answer: pick whichever one you'd rather code. The two algorithms approach the problem completely differently (one sorts all the edges and merges a forest, the other grows a single tree outward), so they'll behave differently on particular graphs, but their running times end up about the same. That suggests there might be something fundamental about how much work finding a minimum spanning tree takes, though nobody has proven a lower bound like the one for comparison sorting

#quote(block: true)[In fact, $O(m log n)$ isn't the best possible. Chazelle's *soft heap* is a priority queue that is allowed to be *wrong* sometimes: it can "corrupt" (raise) the keys of a limited fraction of its items, and in exchange, for a fixed error rate, its operations run in amortized constant time. An algorithm that knows how many errors it could have gotten can then correct for them, and this leads to an MST algorithm that runs in $O(m dot alpha(m, n))$, the same inverse Ackermann function from disjoint sets. We won't cover it in this class, but it's a good reminder that algorithms are never really done]
