#import "../diagrams.typ": graph, marked

#let names = ("A", "B", "C", "D")
#let fw-nodes = (A: (0, 1.8), B: (2.2, 1.8), C: (2.2, 0), D: (0, 0))
#let fw-edges = ("A->B:−1", "B->C:4", "B->D:3", "C->D:−2", "D->A:2")

#let fw-matrix(rows, changed: ()) = table(
  columns: 5,
  align: center,
  [], ..names.map(n => [*#n*]),
  ..rows
    .enumerate()
    .map(((i, row)) => (
      [*#names.at(i)*],
      ..row
        .enumerate()
        .map(((j, x)) => {
          let body = if x == none { $infinity$ } else if type(x) == int { $#x$ } else { [#x] }
          if names.at(i) + names.at(j) in changed { table.cell(fill: marked, body) } else { body }
        }),
    ))
    .flatten(),
)

#let fw-step(k, rows, changed: (), bold: ()) = grid(
  columns: 2,
  column-gutter: 3em,
  align: horizon,
  graph(fw-nodes, fw-edges, highlight: (k,), bold: bold),
  fw-matrix(rows, changed: changed),
)

= Floyd Warshall's Algorithm

The Floyd-Warshall algorithm is our last graph algorithm in lecture, and it's another *shortest path* algorithm. It's also our first real example of *dynamic programming*. You don't need to know what that means yet, but once we see how the algorithm works, it'll be interesting to come back to it

== Why Another Shortest Path Algorithm?

The classic answer is that Floyd-Warshall works with *negative weight edges*. That's true, but recall from the previous chapter that *modified* Dijkstra's (which puts a vertex back into the priority queue whenever it finds a cheaper path to it) also handles negative edges. So Floyd-Warshall has two other things going for it

- *It detects negative weight cycles* - Modified Dijkstra's just loops forever on a negative weight cycle, saying "hey, I can make it better" every time it goes around. Floyd-Warshall finishes, and its answer tells us there's a negative weight cycle, and even which pairs of vertices have no shortest path because of it
- *It finds every shortest path* - Dijkstra's is a *single source* shortest path algorithm: when it finishes, we know the shortest path from one starting vertex to every other vertex. Floyd-Warshall solves *all pairs* shortest paths: when it finishes, we know the shortest path from *every* vertex to *every* vertex

That second point is why Floyd-Warshall shows up so much. Just like a lot of algorithms start with Dijkstra's and build on it, there's a large family of graph analysis algorithms that start by running Floyd-Warshall, since analyzing the structure of a graph often needs every shortest path, and Floyd-Warshall gets us all of them directly

== The Distance Matrix

Floyd-Warshall keeps an $n times n$ matrix `d`, where `d[u][v]` is the cost of the shortest path we know so far from `u` to `v`. When the algorithm finishes, `d[u][v]` will be the true shortest path distance from `u` to `v`, which is why it's called `d`. This is *not* the adjacency matrix from earlier: it starts out looking a lot like one, but it ends up storing distances between vertices that aren't connected by an edge at all

We start by filling in everything we know directly from the graph, without computing any longer paths

- The shortest path from any vertex to itself costs 0, so the diagonal is all 0
- If there's an edge from `u` to `v`, the best path we know from `u` to `v` is that edge, so `d[u][v]` is its weight
- Everything else is $infinity$, since we don't know any path there yet

We'll use the weighted, directed graph in @floyd-init for the rest of the chapter. It has two negative edges, $A -> B$ and $C -> D$, but no negative weight cycles (the cheapest cycle, $A -> B -> C -> D -> A$, costs $-1 + 4 - 2 + 2 = 3$). The edges have directions, so even though there's an edge from $D$ to $A$, there's no edge from $A$ to $D$: entry $(A, D)$ starts at $infinity$, while entry $(D, A)$ starts at 2

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    align: horizon,
    graph(fw-nodes, fw-edges),
    fw-matrix((
      (0, -1, none, none),
      (none, 0, 4, 3),
      (none, none, 0, -2),
      (2, none, none, 0),
    )),
  ),
  caption: [Example: a weighted, directed graph (left) and its initial distance matrix (right). Row $u$, column $v$ is the cost of the best path we know from $u$ to $v$],
) <floyd-init>

Notice what this matrix already is: the shortest paths that use *at most one edge*. Everything that's immediately true from the graph is stored, and that's a hint about how the algorithm works. We're going to compute longer paths by building on what we've already computed, which is basically what every dynamic programming algorithm does

== Allowing One Vertex at a Time

The idea is to grow the set of vertices that paths are allowed to pass *through* (their *intermediate* vertices), one vertex at a time. Right now, our matrix has the shortest paths that go through no other vertices at all. After the first step, it will have the shortest paths that may go through $A$. After the next, the shortest paths that may go through $A$ and $B$, and so on. Once every vertex is allowed, the matrix holds the true shortest paths

When we allow a new vertex $k$, the shortest path from $u$ to $v$ either doesn't use $k$, in which case we already know it, or it goes from $u$ to $k$ and then from $k$ to $v$. Both of those halves only use vertices we've *already* allowed, so their best costs are already in the matrix! So for every pair, we just check

$ d[u][v] > d[u][k] + d[k][v] $

and if it's true, going through $k$ is cheaper, so we update `d[u][v]`. If either half is $infinity$, the path through $k$ doesn't exist, so it can't help, and we can stop right there

=== Through A

@floyd-step-a allows $A$ as an intermediate vertex. Nothing can get *to* $A$ except $D$, so the only candidates are paths from $D$, through $A$, and onward

- $B -> C$ costs 4, and $B -> A -> C$ is $infinity$ (there's no path from $B$ to $A$ at all), so no change. The same goes for every other pair starting at $B$ or $C$
- $D -> B$ is $infinity$, but $D -> A -> B$ costs $2 + (-1) = 1$, which is an improvement, so `d[D][B]` becomes 1
- $D -> C$ is $infinity$, and $D -> A -> C$ is also $infinity$, since $A$ has no path to $C$ yet, so no change

#figure(
  fw-step(
    "A",
    (
      (0, -1, none, none),
      (none, 0, 4, 3),
      (none, none, 0, -2),
      (2, 1, none, 0),
    ),
    changed: ("DB",),
    bold: ("D-A", "A-B"),
  ),
  caption: [After allowing $A$ (highlighted). The only improvement is $D -> A -> B$, which costs $2 + (-1) = 1$],
) <floyd-step-a>

So we now have every shortest path that uses zero vertices in between, plus every shortest path that goes through $A$ and nothing else. We haven't changed the graph: we've just found a *virtual path* from $D$ to $B$ that costs 1, which really means "I know I can get from $D$ to $B$ for 1, by way of $A$"

=== Through B

Now @floyd-step-b allows $B$, so paths can go through $A$, $B$, or both. This is where building on old answers pays off: `d[D][B]` is already 1 from the last step, so we reuse the path through $A$ without recomputing it

- $A -> B -> C$ costs $-1 + 4 = 3$, better than $infinity$
- $A -> B -> D$ costs $-1 + 3 = 2$, better than $infinity$
- $C -> B$ is $infinity$, so nothing from $C$ can go through $B$. Once one half is $infinity$, we can stop
- $D -> B -> A$ needs a path from $B$ to $A$, which we still don't have, so no change
- $D -> B -> C$ costs $1 + 4 = 5$, using the virtual path $D -> A -> B$ we found through $A$, so `d[D][C]` becomes 5

#figure(
  fw-step(
    "B",
    (
      (0, -1, 3, 2),
      (none, 0, 4, 3),
      (none, none, 0, -2),
      (2, 1, 5, 0),
    ),
    changed: ("AC", "AD", "DC"),
    bold: ("A-B", "B-C", "B-D", "D-A"),
  ),
  caption: [After allowing $B$. The new paths are $A -> B -> C$ (3), $A -> B -> D$ (2), and $D -> A -> B -> C$ (5)],
) <floyd-step-b>

=== Through C and D

The last two steps work exactly the same way. Allowing $C$ in @floyd-step-c, the only edge out of $C$ is the $-2$ edge to $D$, and it improves two paths that we *already* had: $A -> D$ drops from 2 to $3 + (-2) = 1$, and $B -> D$ drops from 3 to $4 + (-2) = 2$. Notice how finding a path isn't the end of the story: a longer path with a negative edge can beat a shorter one

#figure(
  fw-step(
    "C",
    (
      (0, -1, 3, 1),
      (none, 0, 4, 2),
      (none, none, 0, -2),
      (2, 1, 5, 0),
    ),
    changed: ("AD", "BD"),
    bold: ("A-B", "B-C", "C-D"),
  ),
  caption: [After allowing $C$. Going through $C$ and its $-2$ edge improves $A -> D$ to 1 and $B -> D$ to 2],
) <floyd-step-c>

Finally, allowing $D$ in @floyd-step-d gives $B$ and $C$ a way back to $A$, since $D -> A$ is the only edge into $A$

- $B -> D -> A$ costs $2 + 2 = 4$, using the $B -> C -> D$ path we just found through $C$
- $C -> D -> A$ costs $-2 + 2 = 0$
- $C -> D -> B$ costs $-2 + 1 = -1$, which is really $C -> D -> A -> B$

#figure(
  fw-step(
    "D",
    (
      (0, -1, 3, 1),
      (4, 0, 4, 2),
      (0, -1, 0, -2),
      (2, 1, 5, 0),
    ),
    changed: ("BA", "CA", "CB"),
    bold: ("B-C", "C-D", "D-A", "A-B"),
  ),
  caption: [After allowing $D$, every vertex is allowed, so this is the final distance matrix: the shortest path from every vertex to every vertex],
) <floyd-step-d>

Every vertex has now been allowed, so @floyd-step-d holds the shortest path from every vertex to every other vertex. For example, the cheapest way from $B$ to $A$ is $B -> C -> D -> A$ for 4, even though $B -> D -> A$ uses fewer edges and costs 5

There's one more thing to notice in each step: row $k$ and column $k$ never change while we're allowing $k$. Going from $u$ to $k$ through $k$ costs $d[u][k] + d[k][k] = d[u][k] + 0$, which is no better than what we had. That's why we can update the matrix *in place* without worrying that we're reading a value we just changed (as long as there are no negative weight cycles, which make $d[k][k]$ negative, as we'll see)

== The Algorithm

+ Create an $n times n$ matrix `d`, with 0 on the diagonal, the edge weight wherever there's an edge, and $infinity$ everywhere else
+ For each vertex $k$, in any fixed order, allow $k$ as an intermediate vertex: for every pair of vertices $u$ and $v$, if $d[u][k] + d[k][v] < d[u][v]$, set $d[u][v] = d[u][k] + d[k][v]$
+ When every vertex has been allowed, `d[u][v]` is the shortest path distance from `u` to `v`

Written as a recurrence, if $d_k (u, v)$ is the cheapest path from $u$ to $v$ whose intermediate vertices are all among the first $k$ vertices, then

$ d_k (u, v) = min(d_(k - 1) (u, v), d_(k - 1) (u, k) + d_(k - 1) (k, v)) $

That recurrence is how we'd show the algorithm is correct. The loops just compute it from the bottom up, in an order where everything on the right-hand side is always ready

== The Code

We number the vertices $0$ to $n - 1$ as usual, and use the largest `int` as $infinity$. Before adding two distances, we check that neither is $infinity$: without that check, $infinity$ plus a positive weight would overflow into a huge *negative* number, which would look like an amazing shortcut

```cpp
const int INF = std::numeric_limits<int>::max();

struct Edge {
    int u;
    int v;
    int weight;
};

using Matrix = std::vector<std::vector<int>>;

/** Finds the shortest distance between every pair of vertices
 * Runtime: O(n^3)
 */
Matrix floydWarshall(int n, const std::vector<Edge>& edges) {
    Matrix d(n, std::vector<int>(n, INF));
    // a vertex reaches itself for 0, and each edge is the best path known yet
    for(int v = 0; v < n; v++) {
        d[v][v] = 0;
    }
    for(const Edge& e : edges) {
        d[e.u][e.v] = e.weight;
    }

    // allow one more middle vertex `k` per pass, so `k` must be the outer loop
    for(int k = 0; k < n; k++) {
        for(int u = 0; u < n; u++) {
            for(int v = 0; v < n; v++) {
                // no known path through `k` (adding to INF would overflow)
                if(d[u][k] == INF || d[k][v] == INF) { continue; }
                if(d[u][k] + d[k][v] < d[u][v]) {
                    d[u][v] = d[u][k] + d[k][v];
                }
            }
        }
    }
    return d;
}
```

=== Does the Order of the Loops Matter?

Yes! The *outer* loop has to be the vertex we're going through, and the two inner loops are the source and the destination. Swapping which variable plays which role breaks the algorithm. The order we visit the vertices in, on the other hand, doesn't matter at all: we could allow $D$ first and $A$ last, as long as every iteration of the outer loop finishes all of its pairs before we move to the next $k$

To see it break, put `k` in the innermost loop instead. Now each pair $(u, v)$ gets looked at exactly once, checking every possible middle vertex, and then never again. On our example, that computes $B -> A$ as 5 instead of 4: when it looks at $(B, A)$, the best path it knows from $B$ to $D$ is still the edge that costs 3, since the cheaper $B -> C -> D$ path for 2 doesn't get found until it looks at $(B, D)$ later. With `k` on the outside, every path through the earlier vertices is finished before anything tries to build on it

== Recovering the Paths

From a theoretician's point of view, the shortest path problem is done once we have the number. But if your car's GPS just said "the road to Chicago is 196 miles" and left it at that, it wouldn't be very helpful. In practice, we want the *path*, not just its length

So we add a second $n times n$ matrix, which we'll call `next`, where `next[u][v]` is the vertex we should go to *first* to get from `u` to `v` along the best path we know. The distance matrix changes exactly the same way as before

- At the start, `next[v][v]` is `v` (to get to yourself, you go to yourself), and for every edge, `next[u][v]` is `v`, since the best path we know is that edge. Everywhere else is empty, since we don't know any path there yet
- Whenever going through $k$ improves `d[u][v]`, the first step from `u` to `v` is now the first step from `u` to `k`, so we set `next[u][v] = next[u][k]`

On our example, allowing $A$ found $D -> A -> B$, so `next[D][B]` becomes `next[D][A]`, which is $A$. Then allowing $B$ found $D -> B -> C$ for 5, so `next[D][C]` becomes `next[D][B]`, which is also $A$: to get from $D$ to $C$, we go to $A$ first. @floyd-next shows the `next` matrix before and after the whole algorithm

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: center + horizon,
    fw-matrix((
      ("A", "B", "", ""),
      ("", "B", "C", "D"),
      ("", "", "C", "D"),
      ("A", "", "", "D"),
    )),
    fw-matrix(
      (
        ("A", "B", "B", "B"),
        ("C", "B", "C", "C"),
        ("D", "D", "C", "D"),
        ("A", "A", "A", "D"),
      ),
      changed: ("AC", "AD", "BA", "BD", "CA", "CB", "DB", "DC"),
    ),
    [Before], [After],
  ),
  caption: [The `next` matrix for @floyd-init. Row $u$, column $v$ is the first vertex on the best path from $u$ to $v$, and the highlighted entries changed while the algorithm ran],
) <floyd-next>

To recover a path, start at the source and keep asking "where do I go next to reach the destination?" until we get there. From $D$ to $C$, `next[D][C]` says go to $A$. From $A$, `next[A][C]` says go to $B$ (we filled that in when we allowed $B$ and found $A -> B -> C$ for 3). From $B$, `next[B][C]` says go to $C$, and we're done. So the path is $D -> A -> B -> C$, with cost $2 - 1 + 4 = 5$, exactly `d[D][C]`, as @floyd-path shows

#figure(
  graph(fw-nodes, fw-edges, highlight: ("D", "C"), bold: ("D-A", "A-B", "B-C")),
  caption: [Following `next` from $D$ to $C$ gives the path $D -> A -> B -> C$, which costs $2 + (-1) + 4 = 5$],
) <floyd-path>

```cpp
Matrix d;
Matrix next;

/** Fills `d` with all-pairs shortest distances and `next` with first steps
 * Runtime: O(n^3)
 */
void floydWarshallWithPaths(int n, const std::vector<Edge>& edges) {
    d.assign(n, std::vector<int>(n, INF));
    next.assign(n, std::vector<int>(n, -1));
    for(int v = 0; v < n; v++) {
        d[v][v] = 0;
        next[v][v] = v;
    }
    for(const Edge& e : edges) {
        d[e.u][e.v] = e.weight;
        next[e.u][e.v] = e.v;
    }

    // allow one more middle vertex `k` per pass, so `k` must be the outer loop
    for(int k = 0; k < n; k++) {
        for(int u = 0; u < n; u++) {
            for(int v = 0; v < n; v++) {
                // no known path through `k` (adding to INF would overflow)
                if(d[u][k] == INF || d[k][v] == INF) { continue; }
                if(d[u][k] + d[k][v] < d[u][v]) {
                    d[u][v] = d[u][k] + d[k][v];
                    // first step toward `v` is now the first step toward `k`
                    next[u][v] = next[u][k];
                }
            }
        }
    }
}

/** Follows `next` from `u` to rebuild the shortest path to `v`
 * Runtime: O(n) (one step per edge on the path)
 */
std::vector<int> path(int u, int v) {
    // -1 means there is no path from `u` to `v`
    if(next[u][v] == -1) { return {}; }
    std::vector<int> p = {u};
    while(u != v) {
        u = next[u][v];
        p.push_back(u);
    }
    return p;
}
```

An empty entry is $-1$, so `path` returns an empty vector when there's no path at all. Storing paths only costs one more $n times n$ matrix, and following one takes time proportional to its number of edges

== Detecting Negative Weight Cycles

When we walked through the example, we skipped pairs like $A$ to $A$, since a path from a vertex to itself can never beat 0. But to detect a negative weight cycle, those are exactly the pairs we need. The loops in the code do check them, and on a normal graph they're unexciting: the diagonal stays 0

Now suppose the edge $B -> C$ cost $-4$ instead of 4, like in @floyd-negative-cycle. Then $A -> B -> C -> D -> A$ costs $-1 - 4 - 2 + 2 = -5$, so it's a negative weight cycle. As the algorithm runs, it finds that there's a cheaper way to get from $A$ to $A$ than staying put: go around the cycle, for $-5$. `d[A][A]` becomes negative, and `next[A][A]` becomes $B$, meaning "the cheapest way to get to $A$ from $A$ is to leave and go to $B$". That makes no sense for a real shortest path, and it's exactly the sign that something's wrong

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    align: horizon,
    graph(fw-nodes, ("A->B:−1", "B->C:−4", "B->D:3", "C->D:−2", "D->A:2"), bold: ("A-B", "B-C", "C-D", "D-A")),
    fw-matrix(
      (
        (-5, -6, -10, -12),
        (-4, -5, -9, -11),
        (0, -1, -5, -7),
        (-3, -4, -8, -10),
      ),
      changed: ("AA", "BB", "CC", "DD"),
    ),
  ),
  caption: [Example: changing $B -> C$ to $-4$ makes $A -> B -> C -> D -> A$ a negative weight cycle that costs $-5$. Floyd-Warshall still finishes, and the negative entries on the diagonal (highlighted) give the cycle away],
) <floyd-negative-cycle>

So the rule is

- If there are no negative weight cycles, every diagonal entry stays 0
- If some `d[x][x]` ends up negative, then $x$ can leave and come back to itself for a negative total cost, so there's a negative weight cycle

```cpp
/** Returns whether any vertex can reach itself for a negative cost
 * Runtime: O(n)
 */
bool hasNegativeCycle() {
    for(size_t v = 0; v < d.size(); v++) {
        // a negative diagonal entry means `v` sits on a negative weight cycle
        if(d[v][v] < 0) { return true; }
    }
    return false;
}
```

It also tells us *which* shortest paths don't exist. If `u` can reach some vertex `x` with a negative `d[x][x]`, and `x` can reach `v`, then a path from `u` to `v` can go around the cycle as many times as it likes, getting cheaper every time, so there is no shortest path from `u` to `v`. Pairs that can't get to the cycle (or can't get from it to their destination) still have perfectly good shortest paths. In @floyd-negative-cycle, every vertex is on the cycle, so *none* of the numbers in the matrix mean anything: they're just how many times the algorithm happened to go around the cycle. That also means that with a negative weight cycle, the numbers can keep shrinking, so a big graph might need a wider type like `long long` to avoid overflowing in the negative direction

== Running Time

This is the most screamingly obvious runtime we've seen in this class. Initializing the diagonal is $O(n)$, copying in the edges is $O(m)$, and the three nested loops each run $n$ times, so the whole thing is $O(n^3)$. It doesn't matter whether the graph is sparse or dense: we just go through the loops $n^3$ times no matter what. The distance matrix takes $O(n^2)$ space, and adding the `next` matrix for paths is another $O(n^2)$

Is that good? To get all pairs from Dijkstra's, we'd run it once from every vertex. Recall that Dijkstra's is $O(m log n)$ with a binary heap, and $O(m + n log n)$ with a Fibonacci heap, so running it $n$ times gives

#table(
  columns: 4,
  table.header([*Algorithm*], [*Any Graph*], [*Sparse ($m approx n$)*], [*Dense ($m approx n^2$)*]),
  [$n times$ Dijkstra's (binary heap)], [$O(n m log n)$], [$O(n^2 log n)$], [$O(n^3 log n)$],
  [$n times$ Dijkstra's (Fibonacci heap)], [$O(n m + n^2 log n)$], [$O(n^2 log n)$], [$O(n^3)$],
  [Floyd-Warshall], [$O(n^3)$], [$O(n^3)$], [$O(n^3)$],
)

So in pure theory, running Dijkstra's from everywhere wins on sparse graphs, and with a Fibonacci heap, it ties on dense ones. But in practice, it's not that simple

- *Fibonacci heaps have bad constants*, which is part of why nobody spends much time on them (and they're not in the standard template library)
- *Floyd-Warshall is very cache friendly*. Your computer's hardware tries to guess what memory you'll want next, and its biggest guess is that if you just used something in memory, you'll want the thing right after it. The inner loop walks straight across rows of a matrix, which is exactly that. Cache is somewhere around 100 to 1,000 times faster than main memory, so an algorithm that keeps hitting cache has a tremendous real-world advantage. Dijkstra's jumps all over memory following edges and heap entries
- *Negative edges*. Plain Dijkstra's doesn't work at all with negative edges, and modified Dijkstra's loses the guarantee that each vertex comes out of the priority queue only once, so it can end up redoing a lot of work for every source. Floyd-Warshall is $O(n^3)$ no matter what the weights are

So if we need every shortest path, especially with negative edges, Floyd-Warshall is a very good solution, and in practice it'll usually win

== Dynamic Programming

The bigger reason to see Floyd-Warshall is to start thinking about *dynamic programming*, one of the most powerful techniques for designing fast algorithms. The idea is

+ Describe the problem in terms of *recursive subproblems*. Here, a subproblem is "the shortest path from $u$ to $v$ using only the first $k$ vertices in between", and the recurrence shows it only needs subproblems with $k - 1$
+ Figure out an order where every subproblem's pieces are solved before we need them. Here, that's the outer loop over $k$
+ Solve each subproblem *once*, iteratively, storing its answer instead of recomputing it every time

We can show the algorithm is correct by describing it recursively, and make it fast by doing each subproblem exactly once in a loop instead of recursing. Running a search from every vertex would rediscover the same pieces of paths over and over, while Floyd-Warshall stores those partial solutions in the matrix and reuses them, like how `d[D][B]` from allowing $A$ got reused to find `d[D][C]` when we allowed $B$

The advantage here is limited, because Dijkstra's is already a really good algorithm that does some of the same trick. It says that to get anywhere, we must take the shortest path to the vertex one hop before it, and it finds shortest paths in order, shortest first, so it never has to recompute one. That's also exactly why basic Dijkstra's only works with non-negative edges, and why modified Dijkstra's gets so much worse: once negative edges can make an old answer wrong, the "I've already computed it" advantage goes away. Most optimizations come down to the same question: how do I avoid doing something I've already done?
