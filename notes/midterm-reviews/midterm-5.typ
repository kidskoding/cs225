#import "../diagrams.typ": array-cells, graph

// Graph from the traversals chapter
#let trav-nodes = (A: (0, 0), B: (1.5, 1.4), C: (1.5, 0), D: (1.5, -1.4), E: (3, 1.4), F: (3, 0), H: (3, -1.4), G: (4.5, 0))
#let trav-edges = ("A-B", "A-C", "A-D", "B-C", "B-E", "C-D", "C-E", "C-F", "D-F", "D-H", "E-G", "F-G", "G-H")
#let all-trav = ("A", "B", "C", "D", "E", "F", "G", "H")

// Graph from the MST chapters
#let prim-nodes = (a: (0, 1.6), b: (1.8, 3.2), c: (3.6, 3.2), d: (1.8, 1.6), e: (3.6, 1.6), f: (1.8, 0), g: (3.6, 0), h: (5.4, 1.6))
#let prim-edges = ("a-b:12", "a-d:3", "a-f:14", "b-c:15", "b-d:5", "c-d:10", "c-e:7", "c-h:1", "d-e:4", "d-f:11", "e-f:13", "e-g:6", "e-h:9", "f-g:2", "g-h:8")
#let mst = ("a-d", "d-e", "b-d", "e-g", "f-g", "c-e", "c-h")

// Graph from the Dijkstra chapter
#let dij-nodes = (A: (0, 1.3), B: (1.8, 2.6), F: (1.8, 0), C: (3.6, 2.6), G: (3.6, 0), D: (4.8, 1.3), E: (5.6, 2.6), H: (5.6, 0))
#let dij-edges = ("A->B:10", "A->F:7", "F->B:2", "F->G:4", "B->C:3", "B->D:8", "G->D:4", "C->D:5", "C->E:5", "D->H:4", "E->H:1", "H->G:1")
#let dij-tree = ("A-F", "F-B", "F-G", "B-C", "G-D", "C-E", "E-H")

= Midterm 5: Graph Algorithms, Probability, and Hashing

This one covers the back half of graphs (how to store a graph, BFS and DFS, minimum spanning trees, shortest paths), the bits of probability the hashing analysis leans on, and hash tables. Throughout, a graph has $n$ vertices and $m$ edges

== Topics Covered

- Graphs
  - Graph Implementations
  - Graph Traversal
  - MST Algorithms Prim's algorithm and Kruskal's algorithm
  - Shortest Path Dijkstra's algorithm and Floyd–Warshall algorithm
- Fundamentals of Probability in CS
- Hashing
  - Properties of a hash function
  - SUHA
  - Types of Hashing
  - Resizing a hash table

== Graph Implementations

*Key ideas*

- *Handshaking*: $sum deg(v) = 2m$, since each edge touches two vertices. A simple graph has $m <= n(n - 1) / 2$, a connected one has $m >= n - 1$. *Sparse* means $m approx n$, *dense* means $m approx n^2$
- *Edge list*: a vector of vertices plus a linked list of edges, each edge storing its two endpoints. Any question about edges means scanning all $m$ of them
- *Adjacency matrix*: edge list plus an $n times n$ matrix whose entry $(i, j)$ points to the edge between $i$ and $j$, or `nullptr`. Fast `areAdjacent`, but a whole row to scan for `incidentEdges` and $O(n^2)$ space no matter what
- *Adjacency list*: edge list plus a doubly linked list of incident edges for each vertex. `incidentEdges(v)` costs $O(deg(v))$, which is the size of the answer. Its one weak spot is `areAdjacent`
- The edge list suits files, the matrix suits a fixed vertex set queried with `areAdjacent`, and the adjacency list is the default everywhere else

*Runtimes*

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

*Common mistakes*

- Writing $O(deg(v))$ for `incidentEdges` on a matrix. The matrix doesn't know which entries are filled, so it checks the whole row: $O(n)$
- Calling `areAdjacent` $O(1)$ on an adjacency list. It walks the shorter of the two lists

== Graph Traversal

*Key ideas*

- A traversal visits every vertex *and* every edge. Vertices go from *unexplored* to *visited*. An edge that reaches a new vertex is a *discovery edge*, and one that leads somewhere already visited is a *cross edge* (BFS) or *back edge* (DFS)
- The graph may be disconnected, so the full traversal is a wrapper: mark everything unexplored, then start a traversal from each vertex that's still unexplored. How many times it starts = the number of *connected components*
- *BFS* uses a queue of (vertex, edge we found it by) pairs. It spreads out in layers, so on an *unweighted* graph its $d$ and $p$ give shortest paths *from the start*
- *DFS* is the same code with a stack: `queue` becomes `stack`, `front` becomes `top`, cross becomes back. The recursive version uses the call stack, and checks the *edge* label (not the vertex) before recursing so it can still find back edges
- A cross edge joins vertices whose BFS distances differ by *at most one*. A back edge goes up to an ancestor still on the stack, and DFS depths say nothing about shortest paths
- Any cross or back edge means a *cycle*. The discovery edges form a *spanning tree* of each component

*Code you should be able to write*

```cpp
void BFS(const Graph& g, int start) {
    std::queue<std::pair<int, int>> q; // (vertex, edge we found it by)
    q.push({start, -1});
    while (!q.empty()) {
        auto [v, e] = q.front();
        q.pop();
        if (vLabel[v] == Label::UNEXPLORED) {
            vLabel[v] = Label::VISITED;
            if (e != -1) { eLabel[e] = Label::DISCOVERY; }
            for (int f : g.adj[v]) {
                int w = g.edges[f].other(v);
                if (vLabel[w] == Label::UNEXPLORED) { q.push({w, f}); }
            }
        } else {
            eLabel[e] = Label::CROSS;
        }
    }
}
```

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: center + horizon,
    graph(trav-nodes, trav-edges, highlight: all-trav, bold: ("A-B", "A-C", "A-D", "B-E", "C-F", "D-H", "E-G"), dashed: ("B-C", "C-D", "C-E", "D-F", "F-G", "G-H")),
    graph(trav-nodes, trav-edges, highlight: all-trav, bold: ("A-B", "B-C", "C-D", "D-F", "F-G", "E-G", "G-H"), dashed: ("A-C", "A-D", "B-E", "C-E", "C-F", "D-H")),
    [BFS: visits $A B C D E F H G$], [Recursive DFS: visits $A B C D F G E H$],
  ),
  caption: [Example: BFS and recursive DFS from $A$, trying neighbors in alphabetical order. Bold edges are discovery edges and dashed ones are cross edges (BFS) or back edges (DFS). BFS puts $E$ at distance 2, while the DFS tree has it 6 edges deep],
) <m5-traversal>

*Runtimes*

The nested loops look like $O(n^3)$, but each vertex's `if` body runs once, so the `for` loop runs $sum deg(v) = 2m$ times in total, and at most $n + 2m$ things ever enter the queue or stack. That gives $O(n + m)$ for both BFS and DFS on an adjacency list. On a matrix, finding neighbors costs $O(n)$ per vertex, so it's $O(n^2)$, and on an edge list it's $O(n m)$

*Common mistakes*

- Saying $O(n^3)$ or $O(n m)$ for BFS on an adjacency list. Count total work across the whole run, not loop bounds multiplied together
- Using BFS distances as shortest paths between two vertices that aren't the start, or on a weighted graph

== Minimum Spanning Trees

*Key ideas*

- Input: a *connected, undirected, weighted* graph. Output: a spanning tree ($n - 1$ edges, no cycles, reaches everything) with the smallest total weight. Distinct weights mean exactly one MST, and ties can allow several
- *Partition property*: split the vertices into $U$ and $V - U$. The cheapest edge with one end on each side belongs to *some* MST. (If a tree skips it, adding it makes a cycle that crosses back on a different crossing edge, and swapping that one out costs no more)
- *Kruskal's*: go through edges cheapest first and keep one only if its endpoints are in different disjoint sets, then `union` them. Grows a *forest* that merges into one tree. The PQ holds *edges* whose weights never change
- *Prim's*: grow *one* tree from a start vertex $s$. Every vertex sits in a min PQ keyed on $d[v]$, the weight of the cheapest single edge from the tree to $v$, and $p[v]$ is the tree end of that edge. Remove the min, then for each neighbor $v$ outside the tree, if $w(m, v) < d[v]$, lower $d[v]$, set $p[v]$, and `decreaseKey`
- `decreaseKey` only makes a key smaller, so it *heapifies up* in $O(log n)$, with a `pos_` array to find the vertex in the heap

#figure(
  scale(85%, reflow: true, graph(prim-nodes, prim-edges, bold: mst)),
  caption: [The MST (bold) of a graph with distinct weights, total weight 28. Kruskal's adds $c h, f g, a d, d e, b d, e g, c e$ and stops after 7 edges. Prim's from $a$ builds the same tree in the order $a d, d e, b d, e g, f g, c e, c h$],
) <m5-mst>

*Code you should be able to write*

```cpp
std::vector<int> prim(const Graph& g, int s) {
    int n = g.size();
    std::vector<int> d(n, INT_MAX);
    std::vector<int> p(n, -1);
    std::vector<bool> inTree(n, false);
    d[s] = 0;
    VertexHeap q(d); // buildHeap on all n vertices, ordered by d
    for(int i = 0; i < n; i++) {
        int m = q.removeMin();
        inTree[m] = true;
        for(const Edge& e : g[m]) {
            int v = e.to;
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

*Runtimes*

#table(
  columns: 4,
  table.header([*Algorithm*], [*General*], [*Sparse ($m approx n$)*], [*Dense ($m approx n^2$)*]),
  [Kruskal's (sorted list or heap)], [$O(m log n)$], [$O(n log n)$], [$O(n^2 log n)$],
  [Prim's, heap + adjacency list], [$O(n log n + m log n)$], [$O(n log n)$], [$O(n^2 log n)$],
  [Prim's, heap + adjacency matrix], [$O(n^2 + m log n)$], [$O(n^2)$], [$O(n^2 log n)$],
  [Prim's, unsorted array], [$O(n^2)$], [$O(n^2)$], [$O(n^2)$],
  [Prim's, Fibonacci heap + list], [$O(m + n log n)$], [$O(n log n)$], [$O(n^2)$],
)

- Kruskal's builds its PQ in $O(m log m)$ (sort) or $O(m)$ (`buildHeap`), then does up to $m$ `removeMin`s and near-constant `find`/`union`s, so both total $O(m log m) = O(m log n)$ (since $log m <= 2 log n$)
- Prim's removes $n$ times but can update $m$ times. An unsorted array makes updates $O(1)$, which wins on dense graphs

*Common mistakes*

- Saying Kruskal's loop runs $n - 1$ times. Some edges get skipped, and a vertex whose only edge is the heaviest one forces the loop to look at all $m$
- In Prim's, setting $d[v]$ to a *path* length. That's Dijkstra's. Prim's only looks at the single edge into $v$
- Forgetting that changing $d[v]$ means fixing the PQ too (heapify up), or using a sorted array, which makes each update $O(n)$

== Shortest Paths

*Key ideas*

- A path's *length* is the sum of its weights, so BFS no longer works
- *Dijkstra's* (single source) - Prim's with one change. $d[v]$ is now the best *path* from $s$ to $v$ seen so far, so the test is $d[u] + w(u, v) < d[v]$. Returns a *shortest path tree* of predecessors, and works on *directed* graphs
- Why it's right: when $u$ comes out, any other route from $s$ to $u$ leaves the finished set at some $x$ with $d[x] >= d[u]$, and the rest of that route can only add weight. That reasoning needs *non-negative* weights
- With a negative edge, a vertex can be finished too early with the wrong $d$. *Modified Dijkstra's* re-queues any vertex whose $d$ improves and runs until the PQ is empty. It's correct with negative edges, but can take exponential time, and never stops on a *negative weight cycle* (shortest paths don't exist there)
- *Floyd-Warshall* (all pairs) - an $n times n$ matrix with 0 on the diagonal, the weight for each edge, and $infinity$ elsewhere. Then allow each vertex $k$ as a middle vertex in turn: if $d[u][k] + d[k][v] < d[u][v]$, update. This is *dynamic programming*:
$ d_k (u, v) = min(d_(k - 1) (u, v), d_(k - 1) (u, k) + d_(k - 1) (k, v)) $
- Floyd-Warshall handles negative edges and *detects* negative cycles: any `d[x][x] < 0` at the end means $x$ sits on one
- The $k$ loop must be the *outermost*. The order the vertices get allowed in doesn't matter

*Code you should be able to write*

```cpp
// d starts as INF, with 0 on the diagonal and each edge's weight
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
```

#figure(
  scale(85%, reflow: true, graph(dij-nodes, dij-edges, highlight: ("A", "B", "C", "D", "E", "F", "G", "H"), bold: dij-tree)),
  caption: [Example: Dijkstra's from $A$ on a directed graph, with the shortest path tree in bold. It removes $A$ (0), $F$ (7), $B$ (9), $G$ (11), $C$ (12), $D$ (15), $E$ (17), $H$ (18). $A -> F -> B$ (9) beats the direct edge $A -> B$ (10) even though it uses more edges],
) <m5-dijkstra>

*Runtimes*

#table(
  columns: 4,
  table.header([*Algorithm*], [*General*], [*Sparse*], [*Dense*]),
  [Dijkstra's, heap + adjacency list], [$O(m log n)$], [$O(n log n)$], [$O(n^2 log n)$],
  [Dijkstra's, heap + adjacency matrix], [$O(n^2 + m log n)$], [$O(n^2)$], [$O(n^2 log n)$],
  [Dijkstra's, unsorted array], [$O(n^2)$], [$O(n^2)$], [$O(n^2)$],
  [Dijkstra's, Fibonacci heap + list], [$O(m + n log n)$], [$O(n log n)$], [$O(n^2)$],
  [$n times$ Dijkstra's (binary heap)], [$O(n m log n)$], [$O(n^2 log n)$], [$O(n^3 log n)$],
  [$n times$ Dijkstra's (Fibonacci heap)], [$O(n m + n^2 log n)$], [$O(n^2 log n)$], [$O(n^3)$],
  [Floyd-Warshall], [$O(n^3)$], [$O(n^3)$], [$O(n^3)$],
)

Floyd-Warshall uses $O(n^2)$ space and runs $n^3$ loop iterations whatever the edge count. On paper, Dijkstra's from every vertex wins on sparse graphs, but Floyd-Warshall is cache friendly and handles negative edges, so it usually wins in practice

*Common mistakes*

- Running Dijkstra's on a graph with negative edges and trusting the answer
- Putting $k$ in an inner loop of Floyd-Warshall. Each pair then gets checked only once, before its halves are final
- Adding to $infinity$ (`INT_MAX`) without checking first, which overflows into a big negative "shortcut"

== Fundamentals of Probability in CS

Every runtime before hashing was a worst case (or amortized worst case). A hash table is our first *probabilistic* data structure: it promises fast operations *in expectation*, not every time

*Key ideas*

- *Average case*: the randomness comes from the *data*. Anyone who knows how the structure works can feed it keys that all collide, and people really have done this
- *Expected case*: the randomness comes from the *algorithm*, like choosing the hash function at random each time we build or resize. Then the bound holds for any input
- *Law of large numbers*: if we run lots of operations with constant expected time, the total is very likely close to (expected time) $times$ (number of operations). Same spirit as amortization, which charged one expensive resize to many cheap inserts
- *Uniform and independent*: SUHA treats each key's index as its own roll of a fair $m$-sided die, so a given index gets hit with probability $1 / m$, and two different keys collide with probability $1 / m$
- *Independent trials multiply*: if each of $k$ independent trials is wrong with probability $p$, all $k$ are wrong with probability $p^k$
- *Complement*: when $P(A)$ is awkward, find $P("not" A)$ and use $P(A) = 1 - P("not" A)$
- *Linearity of expectation*: the expected value of a sum is the sum of the expected values, so an expected count is just the sum of each item's probability of being counted

Worked example: pick a key $k$ in a chaining table with $n$ keys. The $n - 1$ other keys each have a $1 / m$ chance of hashing into $k$'s bucket, so adding those up gives

$ E["other keys in" k"'s chain"] = sum_(j != k) 1 / m = (n - 1) / m $

and any fixed bucket expects $n / m$ keys, the *load factor* $alpha$

*Randomized tests and one-sided error*

- The primality test from lecture picks a random value and checks it. A "not prime" answer is always right, but a single "prime" answer might be wrong. Only one direction can be wrong, so it has *one-sided error*
- That lets us run *more* random trials: a composite has to fool every one, and one catch is enough, so independent trials make a mistake extremely unlikely. Rerunning the *same* trial doesn't help, since it repeats its answer
- Any yes/no test can give true or false positives and negatives. A Bloom filter (on the final) has the same one-sided shape: false positives are possible but false negatives aren't, and its $k$ different hash functions play the part of repeated trials

*Common mistakes*

- Treating average case and expected case as the same. The difference is where the randomness lives
- Writing $n / m$ for the keys sharing a given key's chain. That key isn't sharing with itself, so it's $(n - 1) / m$

== Hashing

*Key ideas*

- A *hash table* implements the dictionary ADT (`insert`, `remove`, `find`) with expected $O(1)$ operations. Its three parts are a *hash function*, a *storage array* of size $m$, and a *collision strategy*
- A hash function $h : K -> {0, dots, m - 1}$ must be
  + *Deterministic*: equal keys get equal indices (different keys are still allowed to collide), so `rand()` is out
  + *Efficient*: $O(1)$. If it costs $O(log n)$, just use an AVL tree
  + *Defined with respect to $m$*: the output fits the table
- In practice it's a *hash* to a big integer, then *compression*, almost always `% m`
- A *collision* is two different keys at one index. The keyspace is far bigger than $m$, so the *pigeonhole principle* makes collisions unavoidable. A *perfect* (one-to-one) hash only exists when the table is at least as big as the keyspace
- *SUHA*: $forall k_1 != k_2, P(h(k_1) = h(k_2)) = 1 / m$. It assumes keys are independent and every index equally likely. Load factor $alpha = n / m$, and $E["find"] = O(1 + alpha)$, which is $O(1)$ if we resize to keep $alpha$ bounded
- No *fixed* hash function satisfies SUHA on every input (someone who knows it can pick keys that all collide), so the honest fix is picking the function at random from a good family on every build or resize

=== Types of Hashing

- *Open hashing*: the array holds pointers and the data lives elsewhere. *Separate chaining*: each bucket is a linked list, and `insert` pushes onto the front
- *Closed hashing*, a.k.a. *open addressing*: the data sits in the array itself, one pair per slot, and a full slot means probing elsewhere
  - *Linear probing*: $h(k, i) = (h(k) + i) mod m$
  - *Double hashing*: $h(k, i) = (h_1 (k) + i dot h_2 (k)) mod m$. The step $h_2 (k)$ can't be 0, and it has to be *relatively prime* to $m$ (no common divisor but 1). Otherwise the probes loop over just some of the slots. A prime $m$ guarantees this. The notes use $h_2 (k) = 5 - (k mod 5)$, which is always 1 to 5
- Linear probing `find` stops at an *empty* slot, since every key sits in an unbroken run of full slots starting at its hash
- `remove` in closed hashing leaves a *tombstone*. `find` probes past it like a full slot, and `insert` reuses it like an empty one
- *Primary clustering*: in linear probing, a key that hashes anywhere into a run lands at its end and makes it longer, so big clusters keep growing. Double hashing spreads colliding keys out with different step sizes

#figure(
  grid(
    columns: 2,
    column-gutter: 1.5em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [`insert(29)`: probes 1, 2, 3], array-cells(none, 8, 16, 29, 4, none, 13, highlight: (1, 2, 3)),
    [`insert(22)`: probes 1 to 6, then 0], array-cells(22, 8, 16, 29, 4, 11, 13, highlight: (0, 1, 2, 3, 4, 5, 6)),
    [`remove(16)`, then `find(29)`], array-cells(22, 8, $dagger$, 29, 4, 11, 13, highlight: (1, 2, 3)),
  ),
  caption: [Example: linear probing with $h(k) = k mod 7$ after 16, 8, 4, 13 land in slots 2, 1, 4, 6. Each later key walks forward to a free slot, and a tombstone ($dagger$) keeps `find(29)` from stopping early. With separate chaining, the same inserts leave bucket 1 as the list $[22, 29, 8]$, since 29 and 22 are pushed onto the front],
) <m5-hashing>

*Code you should be able to write*

```cpp
std::string* ProbingTable::find(int key) {
    // stop after m probes, so a full table can't loop forever
    for (size_t i = 0; i < table_.size(); i++) {
        Slot& slot = table_[probe(key, i)];
        if (slot.state == State::Empty) { return nullptr; }
        if (slot.state == State::Full && slot.key == key) { return &slot.value; }
    }
    return nullptr;
}
```

=== Resizing a Hash Table

- Without resizing, a closed table fills up after $m$ keys and chains grow to $n / m = O(n)$. So once $alpha$ hits a set maximum, allocate roughly *double* the space (rounded up to a prime for double hashing) and *rehash* every key
- A key's index depends on $m$, so copying the old array straight over breaks `find`. Every key has to be inserted again with the new hash, and tombstones get dropped along the way
- Rehashing costs $O(n)$, but the array doubling argument still applies, so `insert` stays *amortized* $O(1)$. It's also the moment to pick a *brand new* hash function, so an attacker has to start over
- Resize somewhere between 60% and 90% full (around 70% is common), before the sharp elbows in the probe count curves

*Runtimes*

#table(
  columns: 4,
  table.header([*Expected probes (SUHA)*], [*Found*], [*Not found*], [*Not found, $alpha = 0.9$*]),
  [Separate chaining], [$1 + alpha / 2$], [$1 + alpha$], [1.9],
  [Linear probing], [$1 / 2 (1 + 1 / (1 - alpha))$], [$1 / 2 (1 + 1 / (1 - alpha)^2)$], [50.5],
  [Double hashing], [$1 / alpha ln (1 / (1 - alpha))$], [$1 / (1 - alpha)$], [10],
)

You don't need to memorize these formulas, just the shapes: all three are fine up to about $alpha = 0.5$, double hashing holds up until around 0.8, and linear probing falls apart first because of clustering. Chaining needs the fewest probes, but each one is a pointer jump, while probing walks neighboring array cells that the cache likes, so double hashing often wins in practice. Chaining is the better pick for *huge* records, and `std::unordered_map` uses it

Overall a hash table gives `find`, `insert` (amortized), and `remove` in $O(1)$ expected but $O(n)$ worst case, while an AVL tree gives $O(log n)$ for all three. Chaining `insert` is $O(1)$ worst case without resizing (push to the front). An AVL tree still wins when we need a real worst-case bound, range or nearest searches, or keys that can't be hashed

*Common mistakes*

- Reading "deterministic" as "different keys get different indices". It only promises that equal keys get equal indices
- Emptying a slot on `remove` in linear probing or double hashing, which makes a later `find` stop too soon
- A double hashing step that can be 0 or shares a factor with $m$ (step 2 in a table of 8 only ever reaches half the slots)
- Treating SUHA as a guarantee. It's an assumption, and any fixed hash function can be beaten by an adversary

== Practice Problems

#set enum(numbering: "1.a.")

+ *(Code)* The BFS code above doesn't record distances or predecessors. What two lines would you add, and where?

  *Answer:* Right after marking `v` visited, add
  ```cpp
  p[v] = (e == -1) ? -1 : g.edges[e].other(v); // other end of e
  d[v] = (e == -1) ? 0 : d[p[v]] + 1;          // one more edge
  ```
  The edge stored in the queue is exactly what we need to recover the predecessor

+ *(BFS trace)* Run BFS from $G$ on the graph in @m5-traversal, trying neighbors in alphabetical order. Give the visit order, each vertex's $d$, and the cross edges.

  *Answer:* Visit order $G, E, F, H, B, C, D, A$. Distances: $G = 0$, $E = F = H = 1$, $B = C = D = 2$, $A = 3$. Discovery edges are $G E, G F, G H, E B, E C, F D, B A$ (7 edges, $n - 1$). The cross edges are the other six: $F C, H D, B C, C A, C D, D A$. $C$ is found from $E$ first, so the later copy that came through $F$ marks $F C$ as cross, and likewise for $D$ ($F$ beats $H$). Each cross edge joins two distances at most 1 apart

+ *(Prim trace)* Run Prim's on @m5-mst starting from $h$. In what order are vertices added, and with which edge? What is $d[f]$ right after $d$ joins the tree?

  *Answer:* $h$, then $c$ (via $h c$, 1), $e$ ($c e$, 7), $d$ ($e d$, 4), $a$ ($d a$, 3), $b$ ($d b$, 5), $g$ ($e g$, 6), $f$ ($g f$, 2). Total 28, the same tree as Kruskal's since every weight is distinct. $d[f]$ becomes 13 when $e$ joins, drops to 11 when $d$ joins, and finally to 2 when $g$ joins

+ *(Dijkstra trace)* Run Dijkstra's from $F$ on the directed graph in @m5-dijkstra. Give the order vertices are removed with their final $d$ and $p$.

  *Answer:* $F$ (0), $B$ (2, $F$), $G$ (4, $F$), $C$ (5, $B$), $D$ (8, $G$), $E$ (10, $C$), $H$ (11, $E$), and last $A$ ($infinity$, none). $D$ starts at 10 through $B$ and drops to 8 through $G$. $H$ starts at 12 through $D$ and drops to 11 through $E$. No edge points into $A$, so it can't be reached

+ *(Floyd-Warshall)* Run Floyd-Warshall on vertices $A, B, C$ with edges $A -> B$ (4), $A -> C$ (3), $B -> C$ ($-2$), $C -> A$ (1), allowing $A$, then $B$, then $C$. Give the final matrix. Is there a negative cycle?

  *Answer:* The initial rows are $A: (0, 4, 3)$, $B: (infinity, 0, -2)$, $C: (1, infinity, 0)$.
  - Allowing $A$: $C -> B$ becomes $1 + 4 = 5$
  - Allowing $B$: $A -> C$ becomes $4 + (-2) = 2$
  - Allowing $C$: $B -> A$ becomes $-2 + 1 = -1$
  The final rows are $A: (0, 4, 2)$, $B: (-1, 0, -2)$, $C: (1, 5, 0)$. The diagonal stays 0, so there's no negative cycle (the only cycles cost $4 - 2 + 1 = 3$ and $3 + 1 = 4$)

+ *(Runtimes)* Give the best running time for each.
  + BFS on a graph stored as an adjacency matrix
  + Prim's on a dense graph ($m approx n^2$). Which priority queue should you use?
  + All-pairs shortest paths on a sparse graph with non-negative weights, in theory
  + Kruskal's with a heap instead of a sorted list

  *Answer:*
  + $O(n^2)$, since every vertex scans its full row to find neighbors
  + The unsorted array, at $O(n^2)$. A binary heap gives $O(n^2 log n)$ because each of the $approx n^2$ updates costs $O(log n)$
  + Running Dijkstra's $n$ times is $O(n^2 log n)$, which beats Floyd-Warshall's $O(n^3)$
  + Still $O(m log m) = O(m log n)$. The $O(m)$ `buildHeap` doesn't help, because the loop can do up to $m$ `removeMin`s at $O(log m)$ each

+ *(True or false, with a reason)*
  + If every edge weight is distinct, Prim's from any start and Kruskal's return the same tree
  + BFS on an unweighted graph finds the shortest path between any two vertices
  + If BFS on a connected graph finds no cross edges, the graph is a tree
  + Floyd-Warshall runs faster on a sparse graph than on a dense one
  + A valid hash function must send different keys to different indices

  *Answer:*
  + True. Distinct weights mean there's exactly one MST, and both algorithms find an MST
  + False. Only shortest paths from the BFS start. Paths between other pairs need another BFS
  + True. Every edge is either discovery or cross, so all $m$ edges are the $n - 1$ discovery edges, which form a spanning tree
  + False. It always runs the three loops $n^3$ times, whatever $m$ is
  + False. Deterministic only means equal keys get equal indices, and the pigeonhole principle makes collisions unavoidable

+ *(Linear probing)* Insert 10, 3, 17, 24, 5 in that order into a table of size 7 with $h(k) = k mod 7$ and linear probing, with no resizing.
  + Draw the table and count the probes
  + Then `remove(17)` and `find(24)`. How many probes does the find take, and what would go wrong if `remove` just emptied the slot?
  + Then `insert(31)`. Where does it go?

  *Answer:*
  + All five keys hash to 3 or 5. 10 goes to slot 3 (1 probe), 3 to slot 4 (2), 17 to slot 5 (3), 24 to slot 6 (4), and 5 hashes to 5 and wraps to slot 0 (3). Table: $[5, -, -, 10, 3, 17, 24]$, 13 probes, $alpha = 5 / 7$
  + 17 leaves a tombstone in slot 5. `find(24)` checks slots 3, 4, 5 (tombstone, keep going), 6: 4 probes. If slot 5 were empty, `find` would stop there and claim 24 isn't in the table
  + $31 mod 7 = 3$. Slots 3 and 4 are full and slot 5 holds a tombstone, which `insert` reuses, so 31 goes into slot 5

+ *(Double hashing)* Insert the same keys 10, 3, 17, 24, 5 into a size 7 table with $h_1 (k) = k mod 7$ and $h_2 (k) = 5 - (k mod 5)$.

  *Answer:*
  - 10: $h_1 = 3$, $h_2 = 5$, probes 3
  - 3: $h_1 = 3$, $h_2 = 2$, probes 3, 5
  - 17: $h_1 = 3$, $h_2 = 3$, probes 3, 6
  - 24: $h_1 = 3$, $h_2 = 1$, probes 3, 4
  - 5: $h_1 = 5$, $h_2 = 5$, probes 5, 3, 1
  Table: $[-, 5, -, 10, 24, 3, 17]$, 10 probes compared with linear probing's 13. For key 5 the probes are $5$, $(5 + 5) mod 7 = 3$, and $(5 + 10) mod 7 = 1$. Since 7 is prime, every step from 1 to 5 eventually reaches all 7 slots

+ *(Probability)*
  + A separate chaining table has $m = 50$ buckets and $n = 200$ keys. Under SUHA, what's the load factor, the expected number of keys in bucket 7, and the expected number of *other* keys in the same chain as a given key $k$?
  + A randomized primality-style test wrongly answers "prime" for a composite number with probability $1 / 4$ per trial, and trials are independent. With 5 trials, what's the chance a composite gets called prime? What's the chance at least one trial catches it?

  *Answer:*
  + $alpha = 200 / 50 = 4$, and bucket 7 expects 4 keys. Each of the other 199 keys lands in $k$'s bucket with probability $1 / 50$, so by linearity of expectation that's $199 / 50 = 3.98$
  + It has to fool all 5 trials: $(1 / 4)^5 = 1 / 1024$. By the complement, at least one trial catches it with probability $1 - 1 / 1024 = 1023 / 1024$
