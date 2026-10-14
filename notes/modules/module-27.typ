#import "../diagrams.typ": graph

#let ex-nodes = (A: (0, 1.3), B: (1.8, 2.6), F: (1.8, 0), C: (3.6, 2.6), G: (3.6, 0), D: (4.8, 1.3), E: (5.6, 2.6), H: (5.6, 0))
#let ex-edges = ("A->B:10", "A->F:7", "F->B:2", "F->G:4", "B->C:3", "B->D:8", "G->D:4", "C->D:5", "C->E:5", "D->H:4", "E->H:1", "H->G:1")
#let neg-edges = ex-edges.slice(0, 11) + ("H->G:−8",)
#let cycle-edges = ex-edges.slice(0, 11) + ("H->G:−13",)
#let done = table.cell.with(fill: luma(235))

= Dijkstra's Algorithm

So far, we've only used edge weights to build minimum spanning trees. Now we'll use them for what most people think of first when they see a weighted graph: finding *shortest paths*. The algorithm we'll use, Dijkstra's algorithm, turns out to be Prim's algorithm with one tiny change, which makes it really easy to understand and to analyze

== Weighted Graphs

From a purely theoretical point of view, a *weight* is just a number attached to every edge, and a *weighted graph* is a graph where every edge has one. That's not very exciting on its own, but weights are what let a graph represent something useful. Without them, the shortest path is just the one with the fewest edges, which breadth-first search already finds for us, since it visits vertices in order of how many edges away they are. With weights, the shortest path can be a completely different path, with more edges but less total weight, so BFS isn't enough anymore

Picture a map of Illinois: the towns (Champaign-Urbana, Kankakee, Bloomington, Joliet, Naperville, Chicago) are vertices, and the roads between them are edges. What could the weights be?

- *Distance* - The obvious choice: how many miles long each road is
- *Travel time* - What map apps actually use. It's distance divided by speed, adjusted for traffic, since an interstate and a one-lane dirt road of the same length shouldn't be weighted the same
- *Cost* - If we're taking an Uber, the weight could be what each leg costs, so the shortest path is the cheapest trip

Costs can even be *negative*. Airlines are required to run a certain number of flights a day out of a small airport like Champaign-Urbana to keep flying there, so when hardly anyone is traveling, they sometimes price the flight from Champaign-Urbana to Chicago so that flying CU to Chicago to Europe is cheaper than flying straight from Chicago to Europe. The leg out of CU effectively has a negative cost. Negative weights are a special case, but they can make real-world sense, and we'll see that they matter a lot to our algorithms

A graph can also store several weights at once (cost, time, distance), and the weight we actually run an algorithm on might combine them, like a heuristic that balances cost against time. From an algorithmic point of view, we don't care what the weights mean. What we do care about is the *conditions* an algorithm runs under: is the graph directed? Can a weight be negative? Some algorithms work in one case and not the other

== Single-Source Shortest Paths

The most basic version of the problem asks: given a weighted graph, what is the shortest path from $A$ to $B$, where the *length* of a path is the *sum of the weights* of its edges? That exact question is very important in AI, but in this class we'll solve a slightly bigger problem, the *single-source shortest path* problem: given one starting vertex $s$, find the shortest path from $s$ to *every* vertex that can be reached from it

Why solve the bigger problem? Because it costs the same. The algorithms we know find shortest paths in order of length, so they find the shortest path to every closer vertex on the way to the farthest one. If $B$ happens to be the farthest vertex from $A$, we'll find every other shortest path before we find the one to $B$, and since we do worst-case analysis, asking only about $A$ to $B$ saves us nothing

The answer is a *shortest path tree*. Just like a spanning tree, every vertex $v$ stores a *predecessor* $p[v]$, the vertex right before it on its shortest path from $s$, so following the predecessors back from any vertex traces its shortest path in reverse

== From Prim's to Dijkstra's

Recall Prim's algorithm: we keep a priority queue of vertices keyed on $d[v]$, start with $d[s] = 0$ and every other $d[v] = infinity$, and repeatedly remove the vertex with the smallest $d$, add it to the tree, and update its neighbors. Dijkstra's algorithm is *exactly the same algorithm*. The only thing that changes is what $d[v]$ means

- *Prim's* - $d[v]$ is the weight of the cheapest single *edge* from the tree to $v$
- *Dijkstra's* - $d[v]$ is the length of the cheapest *path* we know of from $s$ to $v$

So when we remove a vertex $u$ and look at an edge from $u$ to $v$ with weight $w(u, v)$, Prim's compares $w(u, v)$ with $d[v]$, but Dijkstra's compares $d[u] + w(u, v)$ with $d[v]$. Getting to $v$ through $u$ means first getting to $u$, which costs $d[u]$, and then taking the edge

There's one more difference. A spanning tree only makes sense in an undirected graph, so Prim's only works on undirected graphs, but Dijkstra's works on *directed* graphs with no problem at all. @dijkstra-example shows the directed graph we'll use for the rest of the chapter, with $A$ as the source

#figure(
  graph(ex-nodes, ex-edges),
  caption: [Example: a directed weighted graph with 8 vertices and 12 edges. We'll find the shortest paths from $A$],
) <dijkstra-example>

To see why the change matters, imagine treating the edges as undirected and running Prim's from $A$. After $A$ and $F$ join the tree, $G$'s key is 4, since the edge from $F$ to $G$ weighs 4. But it doesn't cost 4 to get from $A$ to $G$: it costs 7 to get to $F$ and then 4 more, so 11. @dijkstra-vs-prim compares the two at that moment

#figure(
  table(
    columns: 3,
    table.header([*Vertex*], [*Prim's key*], [*Dijkstra's $d$*]),
    [$B$], [2, the edge $F -> B$], [9, the path $A -> F -> B$],
    [$G$], [4, the edge $F -> G$], [11, the path $A -> F -> G$],
  ),
  caption: [The values of $B$ and $G$ once $A$ and $F$ are done. Prim's only cares about the last edge, while Dijkstra's stores the whole path's length from $A$],
) <dijkstra-vs-prim>

== Running Dijkstra's Algorithm

We start with $d[A] = 0$ and every other vertex at $infinity$ with no predecessor. Every round, we remove the vertex $u$ with the smallest $d$ from the priority queue. That vertex is now *finished*: $d[u]$ is its true shortest distance, and the edge from its predecessor joins the tree. Then for every neighbor $v$ of $u$ that isn't finished yet, we check whether going through $u$ is better, and if $d[u] + w(u, v) < d[v]$, we lower $d[v]$ to that and set $p[v] = u$

+ *Remove $A$ (0)* - $B$ becomes 10 and $F$ becomes 7, both through $A$
+ *Remove $F$ (7)* - $F$ is the smallest. Going through $F$ to $B$ costs $7 + 2 = 9$, which beats 10, so $d[B]$ drops to 9 and its predecessor changes to $F$. Notice that the direct edge from $A$ to $B$ lost to a path with *more* edges. $G$ becomes $7 + 4 = 11$
+ *Remove $B$ (9)* - $C$ becomes 12 and $D$ becomes 17, both through $B$
+ *Remove $G$ (11)* - Going through $G$ to $D$ costs $11 + 4 = 15$, which beats 17, so $D$'s predecessor changes to $G$
+ *Remove $C$ (12)* - Going through $C$ to $D$ costs $12 + 5 = 17$, which is *not* better than 15, so $D$ doesn't change. $E$ becomes 17
+ *Remove $D$ (15)* - $H$ becomes 19
+ *Remove $E$ (17)* - Going through $E$ to $H$ costs $17 + 1 = 18$, which beats 19, so $H$'s predecessor changes to $E$
+ *Remove $H$ (18)* - $H$'s only neighbor is $G$, which is already finished, so there's nothing to do

@dijkstra-steps draws each round: finished vertices are shaded, bold edges are in the shortest path tree, and dashed edges are each unfinished vertex's current best predecessor. @dijkstra-table lists $d$ and $p$ for every vertex after each round

#figure(
  grid(
    columns: 2,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: center + horizon,
    graph(ex-nodes, ex-edges, highlight: ("A",), dashed: ("A-B", "A-F")),
    graph(ex-nodes, ex-edges, highlight: ("A", "F"), bold: ("A-F",), dashed: ("F-B", "F-G")),
    [Remove $A$ (0)], [Remove $F$ (7)],
    graph(ex-nodes, ex-edges, highlight: ("A", "F", "B"), bold: ("A-F", "F-B"), dashed: ("B-C", "B-D", "F-G")),
    graph(ex-nodes, ex-edges, highlight: ("A", "F", "B", "G"), bold: ("A-F", "F-B", "F-G"), dashed: ("B-C", "G-D")),
    [Remove $B$ (9)], [Remove $G$ (11)],
    graph(ex-nodes, ex-edges, highlight: ("A", "F", "B", "G", "C"), bold: ("A-F", "F-B", "F-G", "B-C"), dashed: ("G-D", "C-E")),
    graph(ex-nodes, ex-edges, highlight: ("A", "F", "B", "G", "C", "D"), bold: ("A-F", "F-B", "F-G", "B-C", "G-D"), dashed: ("C-E", "D-H")),
    [Remove $C$ (12)], [Remove $D$ (15)],
    graph(ex-nodes, ex-edges, highlight: ("A", "F", "B", "G", "C", "D", "E"), bold: ("A-F", "F-B", "F-G", "B-C", "G-D", "C-E"), dashed: ("E-H",)),
    graph(ex-nodes, ex-edges, highlight: ("A", "F", "B", "G", "C", "D", "E", "H"), bold: ("A-F", "F-B", "F-G", "B-C", "G-D", "C-E", "E-H")),
    [Remove $E$ (17)], [Remove $H$ (18)],
  ),
  caption: [Dijkstra's algorithm on @dijkstra-example from $A$. Finished vertices are shaded, bold edges are in the shortest path tree, and dashed edges point from each unfinished vertex's current predecessor],
) <dijkstra-steps>

#figure(
  table(
    columns: 9,
    align: center,
    table.header([*Round*], [*$A$*], [*$B$*], [*$C$*], [*$D$*], [*$E$*], [*$F$*], [*$G$*], [*$H$*]),
    [Start], [0], [$infinity$], [$infinity$], [$infinity$], [$infinity$], [$infinity$], [$infinity$], [$infinity$],
    [Remove $A$], done[0], [*10 ($A$)*], [$infinity$], [$infinity$], [$infinity$], [*7 ($A$)*], [$infinity$], [$infinity$],
    [Remove $F$], done[0], [*9 ($F$)*], [$infinity$], [$infinity$], [$infinity$], done[7 ($A$)], [*11 ($F$)*], [$infinity$],
    [Remove $B$], done[0], done[9 ($F$)], [*12 ($B$)*], [*17 ($B$)*], [$infinity$], done[7 ($A$)], [11 ($F$)], [$infinity$],
    [Remove $G$], done[0], done[9 ($F$)], [12 ($B$)], [*15 ($G$)*], [$infinity$], done[7 ($A$)], done[11 ($F$)], [$infinity$],
    [Remove $C$], done[0], done[9 ($F$)], done[12 ($B$)], [15 ($G$)], [*17 ($C$)*], done[7 ($A$)], done[11 ($F$)], [$infinity$],
    [Remove $D$], done[0], done[9 ($F$)], done[12 ($B$)], done[15 ($G$)], [17 ($C$)], done[7 ($A$)], done[11 ($F$)], [*19 ($D$)*],
    [Remove $E$], done[0], done[9 ($F$)], done[12 ($B$)], done[15 ($G$)], done[17 ($C$)], done[7 ($A$)], done[11 ($F$)], [*18 ($E$)*],
    [Remove $H$], done[0], done[9 ($F$)], done[12 ($B$)], done[15 ($G$)], done[17 ($C$)], done[7 ($A$)], done[11 ($F$)], done[18 ($E$)],
  ),
  caption: [$d[v]$ and, in parentheses, $p[v]$ for every vertex after each round. Shaded entries are finished, and bold entries changed that round],
) <dijkstra-table>

The final shortest distances from $A$ are $A = 0$, $F = 7$, $B = 9$, $G = 11$, $C = 12$, $D = 15$, $E = 17$, and $H = 18$. To get an actual path, we follow predecessors backwards: $H$ came from $E$, which came from $C$, then $B$, then $F$, then $A$, so the shortest path to $H$ is $A -> F -> B -> C -> E -> H$, with length $7 + 2 + 3 + 5 + 1 = 18$

== The Algorithm

+ Set $d[v] = infinity$ and $p[v] = "none"$ for every vertex, then set $d[s] = 0$
+ Build a priority queue of every vertex, keyed on $d$
+ Repeat $n$ times
  + Remove the vertex $u$ with the smallest $d[u]$, and add it to the tree $T$ along with the edge from $p[u]$
  + For every neighbor $v$ of $u$ that isn't in $T$ yet, if $d[u] + w(u, v) < d[v]$, set $d[v] = d[u] + w(u, v)$ and $p[v] = u$ (which updates $v$'s priority in the queue)
+ Return $T$, the shortest path tree

Here it is as pseudocode. Put it next to Prim's and the body is the same, except for the `d[u]` added in the comparison and the update, and that `T.add` records the edge from `p[u]` so we get back the shortest path tree

```cpp
DijkstraSSSP(G, s):
    foreach (Vertex v : G):
        d[v] = +infinity
        p[v] = NULL
    d[s] = 0

    PriorityQueue Q // min distance, defined by d[v]
    Q.buildHeap(G.vertices())
    Graph T // "labeled set"

    repeat n times:
        Vertex u = Q.removeMin()
        T.add(u, p[u])
        foreach (Vertex v : neighbors of u not in T):
            if cost(u, v) + d[u] < d[v]:
                d[v] = cost(u, v) + d[u]
                p[v] = u

    return T
```

== Why It Works

A very reasonable worry is: what if there's some other path we didn't consider? What if a path through lots of light edges beats one heavy edge that we saw early on? @dijkstra-steps already shows what happens for $B$: the direct edge of weight 10 sat in the queue, and before it was ever the smallest thing in there, we found the cheaper path through $F$. The number of edges on a path doesn't matter, only its total weight

Here's the intuition for why it always works. Just like Prim's grows a tree outwards, Dijkstra's grows a *frontier* of finished vertices around $s$, and every round it adds whichever vertex is the shortest distance away from $s$ across that frontier. Suppose we're about to remove $u$, and imagine any path from $s$ to $u$. It starts inside the frontier at $s$, so at some point it has to *cross* the frontier, at some first unfinished vertex $x$. The part of the path up to $x$ is already accounted for in $d[x]$, since $x$'s predecessor on it is finished and updated $x$ when it was removed. And $u$ is the smallest thing in the queue, so $d[u] <= d[x]$. The rest of the path from $x$ to $u$ can only *add* weight, so the whole path is at least $d[x] >= d[u]$. No path can beat $d[u]$, so it's safe to finish $u$

=== Ties

Sometimes two vertices are tied for the smallest $d$. Which one comes out first depends on how our priority queue happens to break ties, and that can change which tree we get. That's fine: we only want *a* shortest path tree, and when there's a tie, both trees have the same distances. The same goes for paths of equal length to one vertex. If the edge from $F$ to $B$ weighed 3 instead of 2, going through $F$ would cost $7 + 3 = 10$, which isn't *less* than 10, so $B$ would keep $A$ as its predecessor, and both paths are equally short

== Negative Edge Weights

There's one assumption hiding in that argument: "the rest of the path can only *add* weight." That's only true if no weight is negative. With a negative edge, we might have to go *farther* in order to go *shorter*, and Dijkstra's has no way to find that path

Let's change the weight of the edge from $H$ to $G$ from 1 to $-8$. There is no negative cycle: the cycle $G -> D -> H -> G$ costs $4 + 4 - 8 = 0$. Dijkstra's runs exactly like @dijkstra-steps, since the first seven rounds never look at that edge. $G$ is finished at 11 and $D$ at 15, and only in the very last round do we see that going through $H$ to $G$ costs $18 - 8 = 10$, but $G$ is already finished, so it's skipped. The real shortest path to $G$ is $A -> F -> B -> C -> E -> H -> G$, with length $7 + 2 + 3 + 5 + 1 - 8 = 10$, which goes all the way out to the farthest vertex and comes back. Even worse, $D$ was finished using the wrong $d[G]$, so its distance is wrong too: it should be 14. @dijkstra-negative compares the two trees

#figure(
  grid(
    columns: 2,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: center + horizon,
    graph(ex-nodes, neg-edges, highlight: ("G", "D"), bold: ("A-F", "F-B", "F-G", "B-C", "G-D", "C-E", "E-H")),
    graph(ex-nodes, neg-edges, highlight: ("G", "D"), bold: ("A-F", "F-B", "H-G", "B-C", "G-D", "C-E", "E-H")),
    [Dijkstra's: $d[G] = 11$, $d[D] = 15$], [True shortest paths: $G = 10$, $D = 14$],
  ),
  caption: [With the edge from $H$ to $G$ changed to $-8$, Dijkstra's (left) gets the shaded vertices wrong. The true shortest path tree (right) reaches $G$ through $H$],
) <dijkstra-negative>

So standard Dijkstra's works by always choosing the shortest thing, knowing that any shorter path would already have been found, and with negative edges that's just not true anymore

=== Modified Dijkstra's

We can fix this with a very small change, which we'll call *modified Dijkstra's*

- Whenever we find a shorter path to *any* vertex, even one that's already been removed, update it and put it back in the priority queue
- Instead of removing exactly $n$ vertices, keep going until the priority queue is empty

On the graph from @dijkstra-negative, the first eight removals are exactly the same. But when we remove $H$ (18), we now update $G$ to $18 - 8 = 10$ with predecessor $H$ and put it back in the queue. $G$ (10) is the smallest thing left, so it comes out again and updates $D$ to $10 + 4 = 14$, which goes back in too. Removing $D$ (14) gives $14 + 4 = 18$ for $H$, which isn't better, so nothing else changes and the queue runs dry. That's the correct tree on the right of @dijkstra-negative

The catch is the running time. A vertex can now come out of the queue many times, once for every time we find a better path to it, so we can no longer say we only remove $n$ things. Usually it does fine, but we can't prove it does: on some graphs with negative edges it takes exponentially long. That's why everyone analyzes and writes about Dijkstra's, and hardly anyone talks about modified Dijkstra's

=== Relaxation

Another way to describe modified Dijkstra's is as a *relaxation* algorithm. Every vertex starts in a tense, high-energy state of $infinity$, and every time we find a better path to it, we *relax* it down to the better value. We keep going until nothing can be relaxed anymore

Seen this way, the priority queue only decides the *order* we try things in. We could make it a plain queue and it would still work (as long as there is an answer), but then we may have to pull a vertex out once for every path to it, which is potentially every edge. CS 374 goes into this basic idea much more, since a huge number of algorithms work by starting everything at $infinity$ and improving it bit by bit

=== Negative Cycles

Now let's make that same edge from $H$ to $G$ weigh $-13$, like in @dijkstra-negative-cycle. The cycle $G -> D -> H -> G$ now costs $4 + 4 - 13 = -5$, so every lap around it *saves* 5. What is the shortest path from $A$ to $H$? There isn't one: whatever length you claim, I can find a cheaper path by going around the cycle one more time

#figure(
  grid(
    columns: 2,
    column-gutter: 2.5em,
    align: center + horizon,
    graph(ex-nodes, cycle-edges, highlight: ("G", "D", "H"), bold: ("G-D", "D-H", "H-G")),
    table(
      columns: 4,
      align: center,
      table.header([*Lap*], [*$G$*], [*$D$*], [*$H$*]),
      [Start], [11], [15], [18],
      [1], [5], [9], [13],
      [2], [0], [4], [8],
      [3], [$-5$], [$-1$], [3],
      [4], [$-10$], [$-6$], [$-2$],
    ),
  ),
  caption: [With the edge from $H$ to $G$ changed to $-13$, the bold cycle costs $-5$. Modified Dijkstra's lowers every vertex on it by 5 per lap, forever],
) <dijkstra-negative-cycle>

So shortest paths simply aren't defined when a *negative weight cycle* can be reached on the way from the start to the destination. Here, $A$, $B$, $C$, $E$, and $F$ still have perfectly good shortest paths, since you can't get back to them from the cycle, but $G$, $D$, and $H$ don't. Modified Dijkstra's has no way to recognize this, so it just keeps saying "hey, I can make it better" and never stops. That's another reason it rarely gets discussed: if there *is* an answer, modified Dijkstra's finds it, but if there isn't, it runs forever

== Implementing Dijkstra's

The pseudocode quietly assumes our priority queue can *update* a vertex's priority when $d[v]$ goes down (*decrease key*). Our heap can do it with the same extra bookkeeping as Prim's (the `pos_` array that tracks where each vertex is in the heap), but the STL's `std::priority_queue` can't do it at all. There are two easy ways around this

- *Use an unsorted array as the priority queue*, just like we did for Prim's. Updating $d[v]$ is just changing a number, and `removeMin` scans every unfinished vertex. The scan takes time, but we only ever remove $n$ things, and we save all the work of building and maintaining a heap
- *Always do modified Dijkstra's*. Instead of updating a vertex in the heap, just push a *new* entry with the better distance. When an entry comes out that's worse than the vertex's current $d$, it's stale, so we throw it out. The heap can now hold up to $m$ entries instead of $n$, since every update adds one

If you had to implement Dijkstra's yourself, the unsorted array version is probably the simplest, but sticking entries back into the STL heap is a perfectly good and reasonable approach. Both versions here use an adjacency list, where `adj[u]` holds the edges leaving `u`

```cpp
struct Edge {
    int to;
    int weight;
};

/** Finds shortest distances from `s` with a lazy heap, skipping stale entries
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
```

- `std::priority_queue` is a max-heap by default, so `std::greater<>` flips it into a min-heap. Pairs compare by their first element (the distance) first
- Unreachable vertices keep `dist` at `INF` and `pred` at $-1$
- There's no "finished" set: a vertex gets processed again whenever its distance improves. With non-negative weights, that never happens after it first comes out, so each vertex is processed exactly once. With negative weights (but no negative cycle), this is exactly modified Dijkstra's, so it still gets the right answer

```cpp
/** Finds shortest distances from `s`, using an unsorted array as the queue
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
```

This one is standard Dijkstra's, with `done` playing the role of $T$: it removes each vertex exactly once and never looks back at finished vertices, so it needs non-negative weights. If the smallest thing left is $infinity$, the rest of the graph can't be reached from `s`, so we stop early

== Running Time

Since Dijkstra's is Prim's with one extra addition, the analysis of Prim's carries over directly. We remove each of the $n$ vertices once, and when we remove $u$, we look at every edge leaving it. Over the whole algorithm, that's every edge exactly once (handshaking again), so we do at most $m$ updates

- *Binary heap and adjacency list* - `buildHeap` is $O(n)$, the $n$ calls to `removeMin` are $O(n log n)$, and the up to $m$ priority updates are $O(m log n)$. That's $O((n + m) log n)$. If every vertex can be reached from $s$, then $m >= n - 1$, so this is $O(m log n)$
- *Binary heap and adjacency matrix* - Finding $u$'s neighbors means scanning its whole row, which is $O(n)$ per vertex and $O(n^2)$ total, so we get $O(n^2 + m log n)$
- *Unsorted array* - Each `removeMin` is an $O(n)$ scan, so that's $O(n^2)$, and each update is $O(1)$, so the total is $O(n^2 + m) = O(n^2)$, with either graph implementation. For a *dense* graph, where $m$ is close to $n^2$, that's actually better than the heap's $O(n^2 log n)$
- *Lazy binary heap (modified Dijkstra's)* - Up to $m$ pushes and pops, each $O(log m)$. Since $m < n^2$, $log m < 2 log n$, so this is still $O(m log n)$, it just uses $O(m)$ space for the heap
- *Fibonacci heap* - A fancier heap where updating a priority is $O(1)$ (amortized), which brings the total down to $O(m + n log n)$. It's the best on paper, but a Fibonacci heap is a giant mess to implement, and it's not in the STL

#table(
  columns: 3,
  table.header([*Priority queue*], [*Graph*], [*Running time*]),
  [Binary heap], [Adjacency list], [$O(m log n)$],
  [Binary heap], [Adjacency matrix], [$O(n^2 + m log n)$],
  [Unsorted array], [Either], [$O(n^2)$],
  [Lazy binary heap], [Adjacency list], [$O(m log n)$],
  [Fibonacci heap], [Adjacency list], [$O(m + n log n)$],
)

Dijkstra's is a great example of reusing the entire structure of an algorithm to do something honestly quite different, and a huge number of graph algorithms turn out to be "Dijkstra's, but then we do something else." Both Prim's and Dijkstra's explore a graph the way a person standing *on* the graph would: start somewhere and walk around, one neighbor at a time. Next, we'll look at an *all-pairs* shortest path algorithm, which can't give an answer for a graph like @dijkstra-negative-cycle (there isn't one), but can at least tell us right away that there isn't one
