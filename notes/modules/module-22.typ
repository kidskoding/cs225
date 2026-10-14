#import "../diagrams.typ": graph

#let g1-nodes = (d: (0, 0), e: (1.3, 0), h: (2.6, 0.7), i: (3.9, 0.7), j: (2.6, -0.7), k: (3.9, -0.7))
#let g1-edges = ("d-e", "e-h", "h-i", "h-j", "h-k", "i-j", "i-k", "j-k")
#let g2-nodes = ("8": (0, 0), "9": (1.2, 0), "0": (2.4, 0), a: (3.6, 0), b: (4.8, 0))
#let g2-edges = ("8-9", "9-0", "0-a", "a-b")
#let g3-nodes = ("4": (0, 0), "1": (0, 1.2), "2": (1.04, 0.6), "3": (1.04, -0.6), "5": (0, -1.2), "6": (-1.04, -0.6), "7": (-1.04, 0.6))
#let g3-edges = ("4-1", "4-2", "4-3", "4-5", "4-6", "4-7")

= Graphs

Graphs are our last *deterministic* data structure. Every data structure we've seen so far is completely determined by its inputs: if I told you what operations you were going to do, you could describe exactly what the data structure would look like. After graphs, we'll move on to *randomized* data structures, where that's no longer true

Looking back, we can split everything we've seen into two halves

- *Linked* data structures, built with pointers: doubly linked lists and most of our trees (binary trees, BSTs, AVL trees, KD trees, B-trees)
- *Array* data structures: sorted and unsorted arrays, stacks and queues (which limit how we use an array for efficiency), heaps (a tree stored in an array), and disjoint sets (uptrees stored in an array)

Arrays really are the fundamental data structure. Memory is just a bunch of bytes in a line, and everything else is built on top of that

== Why Graphs?

We can represent pretty much anything as a graph. It's not always the best way to do it, but it is a very useful one

- *The internet* - Routers are vertices and connections are edges. We want short paths between routers, but also *redundancy*, so if someone digs up a cable with 10,000 connections in it, traffic can take another route
- *Control flow graphs* - A compiler breaks code into *basic blocks*: chunks where if the first instruction runs, all of them run. The blocks are vertices, and the edges are where execution can go next (looping back, branching, returning). A *data flow graph* instead has an edge from wherever a value is written to wherever it's read
- *Literature* - In a graph of a Shakespeare play, characters are vertices, there's an edge whenever two characters talk to each other, and a node's size is how many lines that character has. It shows who's important and how the play flows
- *Exam scheduling* - Each class is a vertex, with an edge between two classes if some student is taking both. Coloring the graph so no edge connects two vertices of the same color tells us how many exam time slots we need. Graph coloring is hard: the best algorithm we know amounts to trying all the options
- *Puzzles* - In a sliding car puzzle, every possible configuration is a vertex, with an edge between two configurations if one move turns one into the other. Solving the puzzle is just finding a path from the start to a winning configuration, and a shortest path algorithm finds the fastest solution
- *Prerequisites* - Classes are vertices, with directed edges for prerequisites
- *State machines* - A machine that decides whether a number is divisible by 7 is just a graph you walk through one digit at a time
- *3D meshes* - The triangles covering the surface of a 3D model form a graph, and we can run graph algorithms on the mesh to ask questions about its structure, like whether it has holes

Graphs also show up when we never build one explicitly. In MP Traversals, the image *is* the graph: every pixel is a vertex, and two neighboring pixels are connected if the neighbor's color is within the tolerance. Often we'll have data we care about for some other reason, and we'll just *treat* it as a graph

That's also why there isn't really one graph ADT. Algorithms usually only care about a small set of questions. A traversal only ever asks "what are the vertices?" and "is $A$ connected to $B$?"

== Graph Vocabulary

A *graph* $G = (V, E)$ is an ordered pair of a set of *vertices* $V$ and a set of *edges* $E$. The number of vertices is $n = |V|$ and the number of edges is $m = |E|$. Yes, $n$ and $m$ are easy to mix up, but that's what everyone uses

@graph-example shows one graph $G$ that we'll use for the rest of the vocabulary. It has three separate pieces, which we'll call $G_1$, $G_2$, and $G_3$

#figure(
  grid(
    columns: 3,
    column-gutter: 2.5em,
    row-gutter: 0.8em,
    align: center + horizon,
    graph(g1-nodes, g1-edges),
    graph(g2-nodes, g2-edges),
    graph(g3-nodes, g3-edges),
    $G_1$, $G_2$, $G_3$,
  ),
  caption: [Example: one graph $G$ made of three pieces, $G_1$, $G_2$, and $G_3$],
) <graph-example>

- *Incident edges* - The incident edges of a vertex $v$ are the edges that touch it: $I(v) = \{(x, v) in E\}$. In @graph-example, the only edge incident on $d$ is the one between $d$ and $e$, while 4 has six incident edges. Asking for a vertex's incident edges is one of the most common things a graph algorithm does. In MP Traversals, they're just the up, down, left, and right neighbors, if they exist
- *Degree* - The degree of $v$ is the number of incident edges, $deg(v) = |I(v)|$. So $deg(d) = 1$ and $deg(4) = 6$
- *Adjacent vertices* - The vertices connected to $v$ by an edge, $A(v) = \{x : (x, v) in E\}$

=== Paths and Cycles

A *path* is a sequence of vertices connected by edges. In theory classes, this is usually called a *walk*, and a path isn't allowed to repeat vertices. In this class, *path* allows repeats: going from 1 to 4 to 2 and back to 4 is a perfectly fine path

A *simple path* is a path that never reuses a vertex. Most of the time, either our paths will be simple just because of the problem, or we won't care

A *cycle* is a path with at least three vertices whose first and last vertices are the same, and that doesn't otherwise reuse any vertices. In @graph-example, $h$, $i$, $k$, $h$ is a cycle

=== Simple Graphs

A *simple graph* has *at most one edge* between any two vertices, and no edge that leaves a vertex and comes straight back to itself (a *self-loop*). Unless we say otherwise, every graph we talk about is simple: most graphs can be made simple, and most algorithms are much easier to reason about on simple graphs

=== Subgraphs

A *subgraph* $G' = (V', E')$ of $G$ is a graph where

- $V' subset.eq V$ and $E' subset.eq E$, so every vertex and edge of the subgraph is in the original graph
- If $(u, v) in E'$, then $u in V'$ and $v in V'$. This just says every edge in the subgraph has *both* of its endpoints in the subgraph. The single vertex 5 is a fine subgraph, but 5 with its edge to 4 (and without 4) isn't a graph at all, since that edge goes nowhere

Some special kinds of subgraphs

- *Complete subgraph* - Every vertex is connected to every other vertex. In @graph-example, $h$, $i$, $j$, and $k$ with all of their edges form a complete subgraph, a $K_4$ hiding inside $G_1$
- *Connected subgraph* - There's a path between every pair of its vertices. $h$, $i$, $j$, $k$ is connected, and so is the line 8, 9, 0, $a$, $b$
- *Connected component* - A connected subgraph that is as big as possible, meaning nothing else could be added to it and keep it connected. $G$ has exactly three connected components: $G_1$, $G_2$, and $G_3$. Just $h$, $i$, $j$, $k$ is connected, but it's not a connected component, since $d$ and $e$ are connected to it too
- *Acyclic subgraph* - A subgraph with no cycles. This is exactly what MP Traversals does: when it reaches a neighbor it has already visited, it doesn't follow that edge, which is the same as removing the edge
- *Spanning tree* - A subgraph that is *connected* and *acyclic* and includes *every* vertex of the graph. It has just enough edges to keep everything connected without any cycles

A graph is *connected* if there's a path from every vertex to every other vertex. A connected graph has one connected component, and a graph with more than one has at least two vertices with no path between them

$G$ isn't connected, so it has no spanning tree at all. But $G_3$ is already a spanning tree of itself. And starting from any connected graph, we can keep removing edges that are part of a cycle until we're left with a spanning tree, like $G_1$ in @graph-spanning-tree. Spanning trees end up being really useful: network routing is built around maintaining spanning trees over a distributed system

#figure(
  grid(
    columns: 2,
    column-gutter: 4em,
    row-gutter: 0.8em,
    align: center + horizon,
    graph(g1-nodes, g1-edges),
    graph(g1-nodes, ("d-e", "e-h", "h-i", "h-j", "h-k")),
    [$G_1$], [A spanning tree of $G_1$],
  ),
  caption: [Removing the edges $i j$, $i k$, and $j k$, which were all part of cycles, leaves a spanning tree of $G_1$ with $6 - 1 = 5$ edges],
) <graph-spanning-tree>

== How Many Edges?

- *Not connected* - The minimum is 0. A graph of isolated vertices with no edges at all is a perfectly fine graph
- *Connected* - The minimum is $n - 1$, since the smallest connected graph is a tree
- *Simple* - The maximum is a *complete graph*, where every vertex is connected to every other vertex. Counting the edges one vertex at a time (without counting any edge twice), the first vertex has $n - 1$ edges, the next has $n - 2$ new ones, and so on, giving $(n - 1) + (n - 2) + ... + 1 + 0 = n(n - 1) / 2$. @graph-complete shows $K_5$ with $(5 dot 4) / 2 = 10$ edges
- *Not simple* - There's no maximum, since we can add as many edges as we want between the same two vertices

#figure(
  graph(
    (a: (0, 1.4), b: (1.33, 0.43), c: (0.82, -1.13), d: (-0.82, -1.13), e: (-1.33, 0.43)),
    ("a-b", "a-c", "a-d", "a-e", "b-c", "b-d", "b-e", "c-d", "c-e", "d-e"),
  ),
  caption: [The complete graph $K_5$ has $(5 dot 4) / 2 = 10$ edges, the most any simple graph with 5 vertices can have],
) <graph-complete>

=== The Handshaking Theorem

$ sum_(v in V) deg(v) = 2m $

If we add up the degrees of every vertex, we get exactly twice the number of edges, since every edge is incident on two vertices and gets counted once at each end. In $G_3$, the degrees add up to $6 + 1 + 1 + 1 + 1 + 1 + 1 = 12 = 2 dot 6$. This holds for non-simple graphs too

This might seem like a quaint little theorem, but almost every graph algorithm from now on gets its runtime from it. Exploring a graph means starting at a vertex, looking at its neighbors, then their neighbors, and so on, which ends up checking the neighbors of every vertex. That's $sum_(v in V) deg(v) = 2m$ work
