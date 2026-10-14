#import "../diagrams.typ": graph, memory, tree

= Midterm 0: Review of Prerequisite Material

Midterm 0 is CS 225's formal introduction to UIUC's Computer Based Testing Facility (CBTF)

Covers the info discussed in course prerequisites, including Graph Theory from *CS 173/MATH 213* and C++ principles from *CS 128/ECE 220*

== Topics Covered

- Course Policies
- Mathematical Foundations
  - Be able to give a closed form solution to a recurrence relation
  - Be able to indicate the big-O running time of common algorithms (eg: binary search, merge sort, etc)
  - Be able to understand basic graph terminology
  - Be familiar with Trees
  - Be able to understand a standard proof and proof by induction
- C++ Topics
  - Classes in C++
    - Public member functions
    - Private helper functions
    - Private variables
    - Constructors
      - Automatic default constructor
      - Custom constructors (default and non-default)
    - Copy constructor
      - Automatic copy constructor
      - Custom copy constructor
    - Inheritance
  - Namespaces in C++
    - Creating a class that is part of a namespace (eg: `Cube` is part of the `cs225` namespace)
    - Using a class from a namespace (eg: `cs225::Cube`)
    - Purpose and usefulness of namespaces
  - Variables
    - Four properties: name, type, location (in memory), and value
    - Primitive vs. user-defined
  - Memory
    - Indirection in C++:
      - Reference variables
      - Pointers
      - Differences and trade-offs between each type
    - Stack memory
    - Heap memory
  - Functions: Calling and Returning
    - Pass by value, by reference, and by pointer
    - Return by value, by reference, and by pointer

== Recursive Definitions

- *Recursive definitions* contain formulas where each term is based on one or more preceding terms
  - Many recursive numerical formulas have something called a *closed form*, which is a closed expression that doesn't involve computing each term in the formula/sequence (similar to a summation)
    - Deriving this closed form is an act known as *unrolling*
      - When unrolling, we substitute a recursive definition into itself until there is an explicit pattern suggesting the closed form expression

For example with the expression,
$
  T(n) &= 2 T(n - 1) + 3 \
  &= 2(2 T(n - 2) + 3) + 3 \
  &= 2(2(2 T(n - 3) + 3) + 3) + 3 \
  &= 2^3 T(n - 3) + 2^2 dot 3 + 2 dot 3 + 3 \
  &= 2^4 T(n - 4) + 2^3 dot 3 + 2^2 dot 3 + 2 dot 3 + 3 \
  &dots.v \
  &= 2^k T(n - k) + 2^(k - 1) dot 3 + dots + 2^2 dot 3 + 2 dot 3 + 3
$

we can use summation notation to represent the $k^"th"$ unrolling step, where
$
  T(n) &= 2^k T(n - k) + 2^(k - 1) dot 3 + dots + 2^2 dot 3 + 2 dot 3 + 3 \
  &= 2^k T(n - k) + 3(2^(k - 1) + dots + 2^2 + 2 + 1) \
  &= 2^k T(n - k) + 3 sum_(i = 0)^(k - 1) (2^i)
$

The input of function $T$ hits the base case when $n - k = 1$, or when $k = n - 1$. Recall that $T(1) = 1$ and substituting $n - 1$ value for $k$ gives

$
  T(n) &= 2^k T(n - k) + 3 sum_(i = 0)^(k - 1) (2^i) \
  &= 2^(n - 1) T(1) + 3 sum_(i = 0)^(n - 2) (2^i) \
  &= 2^(n - 1) + 3 sum_(k = 0)^(n - 2) (2^k) \
  &= 2^(n - 1) + 3(2^(n - 1) - 1) \
  &= 4(2^(n - 1)) - 3 \
  &= 2^(n + 1) - 3
$

therefore making the closed form for function $T$, $2^(n + 1) - 3$

+ Given that $T(0) = 5$, find the closed form solution of
  $ T(n) = T(n - 1) + 2 $

  #enum(numbering: "a.")[
    Unroll the first couple of terms
    $
      T(n) &= T(n - 1) + 2 \
      &= (T(n - 2) + 2) + 2 \
      &= ((T(n - 3) + 2) + 2) + 2 \
      &dots.v \
      &= T(n - k) + 2k
    $
  ][
    where $k = n$ and $T(n) = T(0) + 2n = 5 + 2n$
  ][
    Recall that $T(0)$ can represent any sort of numeric value, where in this case is $5$. This numeric value of $5$ is known as the *base case* and $2n$ is known as the *recursive case*
  ]

+ Given that $T(1) = 3$, find the closed form solution of
  $ T(n) = 2 T(n/2) + n $

  #enum(numbering: "a.")[
    Unroll the first couple terms of the sequence
    $
      T(n) &= 2 T(n/2) + n \
      &= 2(2 T(n/4) + n/2) + n = 4 T(n/4) + 2n \
      &= 2(2(2 T(n/8) + n/4) + n/2) + n = 8 T(n/8) + 3n \
      &dots.v \
      &= 2^k T(n/2^k) + k n
    $
  ][
    where $n/2^k = 1 -> n = 2^k -> k = log_2 n$ and
    $
      T(n) &= 2^(log_2 n) dot T(1) + n dot log_2 n \
      &= n dot T(1) + n log_2 n \
      &= 3n + n log_2 n
    $
  ]

== Proofs by Induction

*Induction* is a technique used to prove recursive definitions/formulas, indicating that it does match its respective closed form solution
- Includes a *base case*, *inductive hypothesis*, and *inductive step*
  - *Base Case* - The starting point, where you prove that it holds true for the smallest value, typically $n = 0$ or $n = 1$
  - *Inductive Hypothesis* - An assumption that the statement being proven is true for some value $k$
  - *Inductive Step* - Prove the inductive hypothesis with the next step $k + 1$

+ Prove that $1 + 2 + 3 + dots + n = (n(n + 1))/2$ for $n >= 1$

  #enum(numbering: "a.")[
    Let $n = 1$, then $(1(1 + 1))/2 = 1$, where $1 = 1$ (both sides are equal)
  ][
    Assume the formula holds true for $k >= 1$, where $1 + 2 + 3 + dots + k = (k(k + 1))/2$
  ][
    Prove the inductive hypothesis from b. for $k + 1$, the next recurring step
    $
      1 + 2 + dots + k + (k + 1) &= ((k + 1)(k + 2))/2 \
      (1 + 2 + dots + k) + (k + 1) &= (k(k + 1))/2 + (k + 1) \
      (k(k + 1) + 2(k + 1))/2 &= ((k + 2)(k + 1))/2
    $
    where the inductive step does indeed hold
  ]

+ Prove $2^n >= n + 1$

  #enum(numbering: "a.")[
    Check if true for $n = 0$
    $
      2^0 &>= 0 + 1 \
      1 &>= 1
    $
    The base case does hold
  ][
    Assume the statement holds for $n = k$, where
    $ 2^k >= k + 1 $
  ][
    Using this assumption, prove it holds for $n = k + 1$
    $
      2^(k + 1) &>= (k + 1) + 1 \
      2^(k + 1) &>= k + 2 \
      2^k dot 2 &>= 2(k + 1) >= k + 2
    $
  ]

== Big-O

Big-O describes how fast a function grows as its input size, $n$, increases. It observes the asymptotic behavior as $n$ gets large.
- measures the efficiency of algorithms
- compares runtime/space usage based on large inputs
- describes the worst case runtime of an algorithm
  - or the *upper bound* of an algorithm, which indicates how bad the algorithm's runtime can get

#table(
  columns: (auto, auto, 1fr),
  table.header([*Big-O Notation*], [*Name*], [*Typical Algorithmic Behavior*]),
  [$O(1)$], [Constant Time], [Accessing a single array element],
  [$O(log n)$], [Logarithmic Time], [Binary Search; algorithm halves the input per iteration],
  [$O(n)$], [Linear Time], [Linear Search; looping over an array once],
  [$O(n log n)$],
  [Log-Linear Time],
  [Merge Sort, Quick Sort, Heap Sort; Divide and Conquer, where problems are broken into subproblems that are solved individually],

  [$O(n^2)$],
  [Quadratic Time],
  [Bubble Sort, Selection Sort, Insertion Sort; Anything involving nested for loops],

  [$O(2^n)$],
  [Exponential Time],
  [Typically many recursive algorithms, including brute force (attempts all possible solutions to a problem until one satisfies the problem's conditions)],

  [$O(n!)$], [Factorial Time], [Permutation-Based Solutions],
)

=== Big-O of Common Algorithms

#table(
  columns: (auto, auto, 1fr),
  table.header([*Algorithm*], [*Big-O Notation*], [*Description*]),
  [Linear Search],
  [$O(n)$],
  [Checks each element one by one from beginning to end looking for the given element],

  [Binary Search],
  [$O(log n)$],
  [Takes in a sorted array and iteratively halves the array that may contain the given value],

  [Bubble Sort],
  [$O(n^2)$],
  [Repeatedly steps through an array and compares adjacent elements, swapping them if they are in the wrong order],

  [Insertion Sort],
  [$O(n^2)$],
  [Iteratively inserts each element of an unsorted list into its correct position in a sorted portion of the list],

  [Selection Sort],
  [$O(n^2)$],
  [Sorts an array by repeatedly selecting the *smallest* element from the unsorted portion and swapping it with the first unsorted element],

  [Merge Sort],
  [$O(n log n)$],
  [Recursively divides an array/list into smaller sublists, where each sublist is sorted and then merged back together into one big list],

  [Quick Sort],
  [$O(n^2)$ with average case of $O(n log n)$],
  [Selects a pivot element from the array and partitions the other elements into two sub-arrays, based on whether they are less than or greater than the pivot],

  [Heap Sort],
  [$O(n log n)$],
  [Organizes elements in an array using a binary heap, by repeatedly swapping the root node (whether it's the maximum or minimum element for max/min heap respectively) with the last element of the heap],
)

== Graphs

Graphs consist of a set of nodes (points/vertices), $V$, and a set of edges, $E$, where the graph is commonly referred to as a pair of sets $(V, E)$.

Each edge in $E$ joins two nodes in $V$, where two nodes connected by an edge are *adjacent* or *neighbors*

Edges can have direction, where graphs with these edges are known as *directed graphs*. This is useful when discussing relations between vertices with contexts to their edges. In contrast, edges that can be traversed in both directions are known as *undirected graphs*

@m0-directed-undirected draws the same four nodes both ways: on the left the edges have no direction, and on the right each edge has an arrow

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    graph((a: (0, 0), b: (1.4, 0), c: (0.7, -1.2), d: (2.1, -1.2)), ("a-b", "a-c", "b-c", "c-d")),
    graph((a: (0, 0), b: (1.4, 0), c: (0.7, -1.2), d: (2.1, -1.2)), ("a->b", "b->c", "c->a", "c->d")),
    [Undirected], [Directed],
  ),
  caption: [Example: $V = {a, b, c, d}$ with four edges; `a` and `b` are adjacent, `a` and `d` are not],
) <m0-directed-undirected>

=== Additional Graph terminology

- *Loops* - a node where an edge connects to itself
- *Multiple Edges* - two nodes are connected by multiple edges
- *Complete Graphs* - Graphs where each node is connected to every other node. They have $(n(n - 1))/2$ edges
- *Walks* - A sequence of nodes and edges, where each edge connects the node before and after it and nodes and edges can repeat
- *Paths* - Walks that *cannot repeat nodes and edges*
- *Cycles* - A path that *starts* and *ends* at the same node
  - *Cyclic Graphs* consist of graphs where nodes are connected in a cycle (non cyclic graphs are called *acyclic*)
- *Wheels* - Cycle Graphs where there exists a *single central node* that connects to every other node in the cycle graph
- *Subgraphs* - A smaller graph made from a subset of vertices and edges of a bigger graph

You can see a complete graph, a cycle, and a wheel side by side in @m0-complete-cycle-wheel. Notice how the wheel is just the cycle plus a center `h` connected to every node

#figure(
  grid(
    columns: 3,
    column-gutter: 3em,
    row-gutter: 0.8em,
    graph(
      (a: (0, 0), b: (1.4, 0), c: (1.4, -1.4), d: (0, -1.4)),
      ("a-b", "a-c", "a-d", "b-c", "b-d", "c-d"),
    ),
    graph(
      (a: (0, 1.2), b: (-1.14, 0.37), c: (-0.71, -0.97), d: (0.71, -0.97), e: (1.14, 0.37)),
      ("a-b", "b-c", "c-d", "d-e", "e-a"),
    ),
    graph(
      (a: (0, 1.2), b: (-1.14, 0.37), c: (-0.71, -0.97), d: (0.71, -0.97), e: (1.14, 0.37), h: (0, 0)),
      ("a-b", "b-c", "c-d", "d-e", "e-a", "h-a", "h-b", "h-c", "h-d", "h-e"),
      highlight: ("h",),
    ),
    [Complete ($4 dot 3 \/ 2 = 6$ edges)], [Cycle], [Wheel],
  ),
  caption: [Example: a complete graph, a cycle graph, and a wheel with center `h`],
) <m0-complete-cycle-wheel>

A graph is *simple* if it does not contain *loops* or *multiple edges*

=== Degree

The degree of a node $v$, notated as $deg(v)$, is the number of edges that are connected to $v$. Loops count *twice* towards the degree of a node.

Each edge contributes to two degrees of a node. Therefore, the *sum of the degrees of all nodes in a graph* is *twice* the number of edges, which can be mathematically expressed as

$ sum_(v in V) deg(v) = 2|E| $

or

$ sum_(k = 1)^n deg(v_k) = 2|E|, quad v_k in V $

This is known as the *Handshaking Theorem*. Let's check it on the graph in @m0-handshaking: the degrees add up to 10, which is twice its 5 edges

#figure(
  graph(
    (a: (0, 0), b: (0, -1.4), c: (1.4, -0.7), d: (2.8, -0.7), e: (4.2, -0.7)),
    ("a-b", "a-c", "b-c", "c-d", "d-e"),
    highlight: ("c",),
  ),
  caption: [Example: $deg(c) = 3$, and the degrees $2 + 2 + 3 + 2 + 1 = 10 = 2 dot 5$ match the 5 edges],
) <m0-handshaking>

=== Isomorphism

Isomorphism exists when two graphs have the same structure, albeit the drawings may be different

Two graphs, $G_1$ and $G_2$ are isomorphic when there exists a bijection of
$ f: V_1 -> V_2 $

Or simply,
- The two graphs must have the same number of nodes and the same number of edges
- For any node degree $k$, the two graphs must have the same number of nodes of degree $k$. For example, they must have the same number of nodes with degree $3$
- Given a subgraph of $G_1$, that subgraph must also exist in $G_2$

In @m0-isomorphic-graphs, $G_1$ and $G_2$ are drawn differently but are isomorphic

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    graph((a: (0, 0), b: (1.4, 0), c: (1.4, -1.4), d: (0, -1.4)), ("a-b", "b-c", "c-d", "d-a")),
    graph((w: (0, 0), x: (1.4, -1.4), y: (1.4, 0), z: (0, -1.4)), ("w-x", "x-y", "y-z", "z-w")),
    [$G_1$], [$G_2$],
  ),
  caption: [Example: isomorphic graphs; $f(a) = w$, $f(b) = x$, $f(c) = y$, $f(d) = z$ maps every edge to an edge],
) <m0-isomorphic-graphs>

=== Connectivity

A graph is *connected* when there exists a walk between every pair of nodes in $G$, or simply you can get from *any node to any other node*, as in the left graph of @m0-connected-disconnected

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    graph((a: (0, 0), b: (1.4, 0), c: (0.7, -1.2), d: (2.1, -1.2)), ("a-b", "a-c", "b-c", "c-d")),
    graph((a: (0, 0), b: (1.4, 0), c: (0.7, -1.2), d: (2.6, 0), e: (2.6, -1.2)), ("a-b", "a-c", "b-c", "d-e")),
    [Connected], [Disconnected],
  ),
  caption: [Example: on the right there is no walk from `a` to `d`],
) <m0-connected-disconnected>

Sometimes removing an edge of a graph will completely lose its connectivity, where such edge is known as a *cut edge*. If removed, the graph would be disconnected. Try removing the edge between `c` and `d` in @m0-cut-edge, and you're left with two separate pieces

#figure(
  graph(
    (a: (0, 0), b: (0, -1.4), c: (1.2, -0.7), d: (2.6, -0.7), e: (3.8, 0), f: (3.8, -1.4)),
    ("a-b", "a-c", "b-c", "c-d", "d-e", "d-f", "e-f"),
    highlight: ("c", "d"),
  ),
  caption: [Example: `c-d` is a cut edge; removing it leaves ${a, b, c}$ and ${d, e, f}$ disconnected],
) <m0-cut-edge>

An *Euler Circuit* exists when there is a closed walk (circuit) that uses every edge of the graph once. This can only occur when *all degrees of the nodes are even*. This is because in order to complete the circuit, you must leave each node that you enter. This means that the graph is *connected* and therefore exists a closed walk that uses every edge of the graph once. In @m0-euler-circuit, for example, every node has an even degree, so a circuit starting and ending at $a$ covers each edge exactly once.

#figure(
  graph(
    (a: (0, 0), b: (0, -1.4), c: (1.2, -0.7), d: (2.4, 0), e: (2.4, -1.4)),
    ("a-b", "b-c", "c-a", "c-d", "d-e", "e-c"),
  ),
  caption: [Example: every degree is even ($deg(c) = 4$, the rest are 2), so the circuit $a, b, c, d, e, c, a$ uses each edge once],
) <m0-euler-circuit>

=== Bipartite Graph

A graph $G = (V, E)$ is *bipartite*, such that $V$ can be split into two nonoverlapping subsets $V_1$ and $V_2$, where every edge connects to an element of $V_1$ in $V_2$.

What this simply means is that *a graph can only be bipartite when* $chi(G) = 2$. This means that a graph can only be colored with *two colors*, like @m0-bipartite, where the shaded nodes $a, b, c$ get one color and $x, y, z$ get the other

#figure(
  graph(
    (a: (0, 0), b: (0, -1.4), c: (0, -2.8), x: (2.5, 0), y: (2.5, -1.4), z: (2.5, -2.8)),
    ("a-x", "a-y", "b-y", "b-z", "c-y", "c-z"),
    highlight: ("a", "b", "c"),
  ),
  caption: [Example: $V_1 = {a, b, c}$ (shaded) and $V_2 = {x, y, z}$; every edge crosses sides, so two colors suffice],
) <m0-bipartite>

== Trees

*Trees* are undirected graphs with a special node called the *root*, where every node is connected to the root via one exact *path*

They are also *acyclic*, *connected*, and have $n$ *vertices* with $n - 1$ *edges*

=== Tree Vocabulary

- *Parent* - A node that is directly above another node in a tree
- *Child* - A node that is directly below another node in a tree
- *Sibling* - Nodes that *share the same parent*
- *Leaf* - A node that has no children
- *Internal* - A node that has at least one child
- *Level* - The number of edges from the *root* to the node (the root has a level of $0$)
- *Height* - The longest path from a node to a leaf (in terms of edges)
- *Ancestor* - The ancestor of a node is one that lies on the path from the root to such node
- *Descendant* - The descendant of a node is one that lies on the path from such node to a leaf node

Try matching these terms to the small tree in @m0-tree-vocabulary. For example, `B` is an internal node at level 1, and `A` is an ancestor of every other node

#figure(
  tree(("A", ("B", "D", "E"), ("C", none, "F"))),
  caption: [`A` is the root and the parent of siblings `B` and `C`; `D`, `E`, and `F` are leaves; the tree has height 2],
) <m0-tree-vocabulary>

=== $m$-ary Trees

$m$-ary trees are trees that can have at most $m$ children. A common type of tree is a *Binary Search Tree*, where each node has at most $2$ children.

- *Full* trees exist when each node has either $0$ or $m$ children
- *Complete* trees exist when all levels are completely filled, except for the lowest one, which is filled from the left
- A tree is *full* and *complete* when the whole bottom level is fully populated with leaves
- *Balanced* trees exist when the heights of its left and right subtrees *differ by at most* $1$

Going left to right in @m0-full-complete-trees, the first tree is full, the second is complete, and the third is both. For balance, compare the two trees in @m0-balanced-trees: node `1` on the right has a left subtree that is two levels taller than its right

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    tree((1, (2, 4, 5), 3)), tree((1, (2, 4, 5), (3, 6, none))), tree((1, (2, 4, 5), (3, 6, 7))),
  ),
  caption: [Binary trees that are full, complete, and both full and complete (left to right)],
) <m0-full-complete-trees>

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    tree((1, (2, 4, none), 3)), tree((1, (2, (3, 4, none), none), 5)),
    [Balanced], [Not balanced],
  ),
  caption: [Example: on the right, node `1` has a left subtree of height 2 and a right subtree of height 0],
) <m0-balanced-trees>

There are $m i + 1$ nodes total in a $m$-ary tree. This means a binary tree has $2i + 1$ nodes total. You can count this yourself on the full 3-ary tree in @m0-mary-node-count, which has 2 internal nodes and $3 dot 2 + 1 = 7$ nodes

#figure(
  tree((1, (2, 5, 6, 7), 3, 4)),
  caption: [Example: a full 3-ary tree with $i = 2$ internal nodes (`1` and `2`) has $3 dot 2 + 1 = 7$ nodes],
) <m0-mary-node-count>

=== Height and number of nodes

There is no exact formula to find the number of nodes and leaves in an $m$-ary tree. This is because some trees are more bushier (have more children) than others.

However, there are some patterns *(assuming that a given tree is binary)*

- The number of nodes are maximized when a tree, with height $h$, is full and complete is $2^h$
  - where the number of nodes at level $L$ are $2^L$ and the total nodes are $sum_(L = 0)^h 2^L$, with a closed form of $2^(h + 1) - 1$

=== Public vs Private

Each member of a class in C++ has a specific *access level* that determines how that member can be accessed

A member can be one of three types: *public*, *private*, or *protected*
- `private` - Members declared as private can only be accessed from *within the same class*
- `protected` - Members declared as protected can only be accessed by derived classes (subclasses)
- `public` - Members declared as public can be accessed *anywhere* (inside the class, from other classes, or even outside the class)

#table(
  columns: 4,
  table.header([*Access Specifier*], [*Access within Class*], [*Access in Derived Class*], [*Access Outside Class*]),
  [`public`], [Yes], [Yes], [Yes],
  [`protected`], [Yes], [Yes], [No],
  [`private`], [Yes], [No], [No],
)

==== Classes vs Structs

#quote(block: true)[Members of a `struct` are `public` by default]

#quote(block: true)[Members of a `class` are `private` by default]

That is the simple difference between a `class` and a `struct`

The keywords `public` `protected` and `private` can explicitly define access levels of functions and variables for both a struct or class.

However, it is *best practice* for a struct to not use any access specifiers (all members will anyway default to `public`) and for a class to make member variables `private` (or `protected`) and methods `public`

A `struct` is typically used when
- There is a simple collection of data that doesn't benefit from restricting access
- Aggregate initialization is sufficient (no need for object)
- Structs should be aggregates by convention, where direct initialization of members are allowed through an initializer list `{ }` and there are no *constructors*, no *private/protected access members*, no *virtual functions*, and no *base classes*

Otherwise, just use classes

==== Member Functions

*Member functions* are functions that belong to a class type. This means that they can be called on an instance of that class type (e.g. `e.getData()`, where `getData()` is a member function of object type `e`)

- This means they are declared in the class definition!

#quote(block: true)[C\# and Java refer to these as methods, since they are object oriented languages at the core. They aren't referred to as methods in C++, but the idea still remains the same]

Functions that don't belong to a class are *non-member functions* or simply *free functions*.

With free functions, the object must be explicitly passed into the function, while with member functions, the object is implicitly passed and accessed through that object with the dot operator (`.`)

Member functions can sometimes create more clarity on what is doing the action!

=== Constructors

*Constructors* are special functions automatically called after a non-aggregate class type is created

- If an accessible matching constructor is found, then memory for the object is allocated and the constructor function is called. Otherwise, a compilation error is generated

They can also be *overloaded*, like functions

By convention, constructors *initialize member variables* (via a member initialization list) and perform *other setup functions* (error checking initialization values, opening a file or database, etc.)

Constructors must *have the same name as the class* and have *no return type* (not even `void`)

Class members are initialized in a constructor as follows via an initializer list, which initializes the member variable to the parameter variable

```cpp
class Foo {
    int m_x;
    int m_y;
    public:
        Foo(int x, int y) : m_x{ x }, m_y{ y } { }
};
```

This is the proper way to initialize member variables.

The code below does the same thing, but its technically not initializing, but rather assigning. This means that `m_x` and `m_y` may go uninitialized

```cpp
class Foo {
    int m_x;
    int m_y;

public:
    Foo(int x, int y) {
        m_x = x;
        m_y = y;
    }
};
```

A *default constructor* is one that accepts no arguments, meaning that it has been defined with no parameters. Suppose, class `Foo` exists where the only constructor that exists is the default constructor

```cpp
class Foo {
public:
    Foo() { }
};
```

When creating an object, like `Foo f;` or `Foo f2{};` the *default constructor* is called, which doesn't do anything in this example

If no constructor is given, then the compiler will generate a public default constructor that does nothing, equivalent to the example above. This is known as an *implicit default constructor*

Instead of explicitly stating a default constructor, like `Foo() { }`, we can use the default keyword to have the compiler explicitly generate a default constructor for us. This is shown in the example below

```cpp
class Foo {
public:
    Foo() = default;
};
```

With a user defined constructor, member variables are not automatically initialized (you need to do it yourself). With compiler provided constructors (either `= default` or implicitly provided), the members are also left uninitialized for `Foo f;`. The compiler only zero initializes them when the object is value initialized, like `Foo f{};`

Therefore, only create a default constructor when it makes sense for objects of a class type to be created using all default values

=== Namespaces

*Namespaces* group together related code (variables, functions, classes, etc.) under a name to avoid naming conflicts.
- The built in `cout` function for console output belongs to the standard `std` namespace, which is why we namespace it with `std::cout`
- This avoids naming conflicts in case we decided to make our own `cout` function (this actually was a thing back in old C++, where `cout` didn't belong to the `std` namespace)
- There is a way to get around this with `using namespace std`, but if we end up defining our own `cout` function, this causes a *namespacing collision* and our code won't compile!

== References and Pointers

A *reference* is an alias of an existing object. It refers to the same object in memory with a different *name*. References are notated with an `&`

```cpp
int x = 10;
int& xRef = x;
xRef = 20;

// After x will also become 20 because they refer to the same memory
```

After running the code above, `x` will also become 20 because `x` and `xRef` refer to the same address in memory, which is why @m0-reference-memory has just one box with both names on it

#figure(
  memory(stack: ("x, xRef": 20)),
  caption: [`xRef` is not a new box: it is a second name for the memory of `x`],
) <m0-reference-memory>

*Note that this is called an lvalue reference in modern C++*

A *pointer* is a variable that *stores the memory address* of another variable, thereby "pointing" to that variable's address in memory
- `*` is the syntax used after a type to declare a pointer type and it is used in conjunction with `&` (the address of operator) to get a variable's address in memory!
- `*` (dereferencing operator) is also used to dereference a pointer to access the value that it points to
- Pointers can be *null* (meaning they point to nothing!)
- Dereferencing these pointers can lead to undefined behavior (segmentation fault!)
- `nullptr` keyword can be used to check if a pointer is null! This also avoids dangling pointers!
- `NULL` and `0` can also reference null pointers. `NULL` comes from `C`, while `0` is an address that typically represents a null pointer. However `0` and `NULL` should be avoided in modern C++ in favor of `nullptr`

```cpp
int x = 7;
int* xPtr = &x;
std::cout << *xPtr << std::endl;
```

The code snippet above still prints `7` to the console because it is dereferencing the pointer's value! Unlike the reference above, `xPtr` gets its own box in @m0-pointer-memory, and that box holds the address of `x`

#figure(
  memory(stack: (xPtr: "->x", x: 7)),
  caption: [`xPtr` is its own variable holding the address of `x`, so `*xPtr` reads 7],
) <m0-pointer-memory>

Since a pointer points to the memory address of another variable, it is important to initialize a proper memory address to it. Leaving a pointer *uninitialized* can cause problems!

A pointer is *very similar* to a reference. However, a *reference* is an alias that always refers to one fixed variable, while a *pointer* stores the *memory address* of any variable (or nothing/null). Try to use *references* over pointers because pointers can be dangerous

*Dangling Pointers and References* are those that happen when they refer to memory that's no longer valid (usually because the object was destroyed or went out of scope)

- *Dangling pointer:* A pointer points to memory that has been freed or deleted
- *Dangling reference:* A reference refers to an object that no longer exists (e.g., a local variable that went out of scope)

These can be *dangerous* because they can lead to *undefined behavior*, *crashes*, or *data corruption* (see @m0-dangling-pointer for a pointer left holding freed memory)

#figure(
  memory(stack: (p: "->h"), heap: (h: [_freed_])),
  caption: [Example: after `delete p;`, the dangling pointer `p` still holds the address of freed memory],
) <m0-dangling-pointer>

== Dynamic Memory Allocation

*Dynamic Memory Allocation* assigns memory space during a program's execution rather than compile time. This memory that the program uses is generally divided into the *stack* and the *heap*.

=== `new` and `delete`

C++ supports static and automatic memory allocation. *Automatic allocation* creates variables that live only while the function runs (on the stack), while *static allocation* creates variables that stay alive for the whole program (in static memory). The period in which a variable stays alive is known as its *lifetime*

Lifetime based on allocation type
- *Automatic objects*: lifetime ends when they go *out of scope* (e.g., when a function/block ends)
- *Static objects*: lifetime ends when the *program terminates*

With these two methods, the size of the variable/array must be known at compile time, and memory allocation and deallocation happen automatically (when a variable is instantiated/destroyed)

However, there may be situations where declaring a fixed size memory may lead to a waste of unused memory or there are more allocated objects of memory than what was assigned.

To fix this problem, memory can be manually managed dynamically, which is known as *dynamic memory allocation*. This is done using two keywords `new` and `delete`

`new` - *Dynamically allocate memory at runtime on the heap for an object/array*. Also calls the *constructor* to initialize the object and returns a typed pointer to the allocated memory
- This is very similar to `malloc` in C (both allocate memory on the heap), but `malloc` does not call a constructor. Also, `malloc` returns a void pointer (`void*`) and needs to be casted to the appropriate pointer type. Therefore in modern C++, `new` is highly recommended.

`delete` - *Frees memory allocated by* `new`. Also calls the *destructor* to clean up the object. Must match the type of allocation (`delete` for single objects and `delete[]` for arrays)
- Ensure that the pointer points to a valid object (has a valid address of memory!). Otherwise, unpredictable behavior can happen!
- Similar to `free` in C, but since there are no destructors, `free` won't call the destructor if there is any
- *Ends the lifetime of the object the pointer points to!*

Note that when you use `delete`, even though the object is freed from memory, its pointer now points to *invalid memory*. This is a *dangling pointer*. Therefore, it is best practice to set the pointer to `nullptr` (null) after using `delete`, as suggested in the code snippet below, which avoids the dangling pointer.

```cpp
int* xPtr = new int(5);
delete xPtr;
xPtr = nullptr;
```

Comparing the two sides of @m0-new-delete-memory, the `int` on the heap is gone after the `delete`, and `xPtr` now safely holds `nullptr`

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    memory(stack: (xPtr: "->h"), heap: (h: 5)), memory(stack: (xPtr: "nullptr")),
    [Allocated], [Deleted],
  ),
  caption: [After `new int(5)` (left) and after `delete xPtr; xPtr = nullptr;` (right): the pointer lives on the stack, the `int` on the heap],
) <m0-new-delete-memory>

While static and automatic memory management free variables from memory its lifetime ends or out of scope respectively, memory must be explicitly freed with `delete` when dynamically allocated.

#quote(block: true)[In other words, when creating memory calls with `new` they *must* be freed with `delete`.]

Otherwise, a *memory leak* happens. *Memory leaks* occur when a program allocates memory via `new`, but never frees it via `delete`. This causes unused memory, which can eventually exhaust available memory if it happens repeatedly. In @m0-memory-leak, for example, `p` gets pointed at a new `int`, so nothing points to the old block `h1` anymore

#figure(
  memory(stack: (p: "->h2"), heap: (h2: 6, h1: 5)),
  caption: [Example: after `int* p = new int(5); p = new int(6);` nothing points to `h1`, so it can never be deleted],
) <m0-memory-leak>

=== Destructors

A *destructor* is another special kind of class member function that runs when an object of that class is *destroyed*, using `delete`. While constructors initialize instances of a class, destructors help clean them up

When objects go out of scope or a dynamically allocated object is explicitly deleted using `delete`, the class destructor (if it exists) is automatically called to do any necessary clean up of the object before it is freed from memory

Like constructors, destructors also have specific naming rules

+ Must have *same name* as the class (like a constructor)
+ Cannot have a *return type* (like a constructor)
+ Cannot take *any arguments*

Suppose `Foo` is a class with a default constructor (`Foo() = default;`). The destructor for `Foo` is like the one below

```cpp
~Foo() {

}
```

=== RAII

*Resource Acquisition Is Initialization*, or RAII, is a C++ programming design pattern that explains how to manage resources safely in a class through a constructor and a destructor. RAII is used heavily in the C++ STL (standard template library) for efficient resource management in objects.

#quote(block: true)[*RAII* - You acquire a resource (memory, file, lock, etc.) via an object's *constructor* and you automatically release that resource via the object's *destructor*]

In other words, an object *acquires* a resource in its *constructor* and *releases* it in its *destructor*

These resources can include anything the class owns or manages
- A file handle
- A pointer to dynamic memory
- A mutex lock
- A network connection

RAII is a basic technique that explains best practices towards writing a class by *tying an object's resources to its lifetime*

- An object acquires a resource in its constructor, and releases it via its destructor when its lifetime ends

=== Heap

The heap, also known as the *free store*, *tracks memory used for dynamic memory allocation*

Recall that `new` allocates memory and returns a pointer that points to that allocated memory. In contrast, `delete` frees the allocated memory towards the operating system to decide what to do with that memory next.

This dynamic memory allocation behavior is all managed via the heap. This means that `new` will allocate memory onto the heap and `delete` will return the allocated memory from the heap, where the operating system can decide what to do with this memory later.

*Heap Advantages and Disadvantages*

- Allocating memory on the heap is slow
- Allocated memory stays allocated until the programmer deallocates the memory themselves or the application ends (OS cleans it up)
- Even though an OS will clean up dynamically allocated memory at the end of the program, *memory leaks* are still bad practice and you should always `delete` dynamically allocated memory
- This is a problem for bigger programs that handle lots of data, where they can possibly slow down, crash, or cause system instability
- Dynamically allocated memory must be accessed through a pointer. Therefore, dereferencing a pointer is slower than accessing a variable directly
- Because the heap is a big pool of memory, large arrays, structures, or classes can be allocated here

=== Stack

The *stack*, formally referred to as the *call stack*, keeps track of all active functions (ones that have been called and not terminated) from the start of the program to the current point of execution. It also handles allocation of all function parameters and local variables

It stores
- *Local Variables* - function parameters and variables declared inside functions
- *Function call information* - where to return after a function finishes

When a function is called, a stack frame is created on top of the call stack that holds the function's local data. When the function ends, its stack frame is removed, and the memory is automatically reclaimed

*Key Details*

- The stack is *fast* because elements are accessed in a *LIFO* (Last In First Out) format. This means that both removal and insertion is $O(1)$
- Variables in the stack have automatic storage duration and only exist when the function is running
- Limited size (few MBs), so you can run out of stack space if you create too many local variables or deep recursion

All in all, the *stack* is memory for *local variables* that are automatically managed and exist only when a function is *running*. The *heap* is slower memory for *dynamically allocated variables* (`new`) that must be managed *manually* with `delete`
- *Stack data*: local variables inside functions, function parameters, pointer variables themselves (not what they point to)
  - Used for short-lived, simple variables
- *Heap data*: Any variable dynamically allocated via `new` or `malloc`
  - Use when a variable is needed to outlive the function or for large or dynamically-sized data

Looking at @m0-stack-heap, notice that the pointer `p` itself is stack data, and only the `int` it points to is on the heap

#figure(
  memory(stack: (p: "->h", a: 3), heap: (h: 4)),
  caption: [Example: `int a = 3; int* p = new int(4);` puts `a` and the pointer `p` on the stack and the `int` it points to on the heap],
) <m0-stack-heap>

=== Passing Arguments

There are three ways to pass arguments into a function

+ *By Value* - A copy of the argument is made; changes inside the function do *not* affect the original

  ```cpp
  void foo(int x) {
      x = 10;
  }
  ```

  In the example above, assigning `x = 10` only changes the local variable in the function. It does not affect the original `x` parameter being passed into the function. Instead, it creates a copy of `x` and changes that, which is why `n` still holds 5 in @m0-pass-by-value-memory.

  #figure(
    memory(stack: (n: 5, x: 10)),
    caption: [Example: after `foo(n)` with `n = 5`, only the copy `x` holds 10],
  ) <m0-pass-by-value-memory>

+ *By Reference* - The function receives an alias to the original argument; changes affect the caller's variable

  ```cpp
  void foo(int& x) {
      x = 10;
  }
  ```

  In the example above, assigning `x = 10` changes the original `x` parameter to `10`. Notice in @m0-pass-by-reference-memory that `n` and `x` share a single box

  #figure(
    memory(stack: ("n, x": 10)),
    caption: [Example: inside `foo(n)`, `x` is another name for the caller's `n`, so `n` becomes 10],
  ) <m0-pass-by-reference-memory>

+ *By Pointer* - The function receives a pointer to the original variable, where you must dereference to modify

  ```cpp
  void foo(int* x) {
      *x = 10;
  }
  ```

  In the example above, the function receives a pointer to the original parameter of `x`, which must be dereferenced with `*` to modify the original parameter (see @m0-pass-by-pointer-memory, where `x` points at `n`)

  #figure(
    memory(stack: (x: "->n", n: 10)),
    caption: [Example: inside `foo(&n)`, `x` holds the address of `n`, so `*x = 10` sets `n` to 10],
  ) <m0-pass-by-pointer-memory>

=== Returning Values

Same three ways variables are passed into a function, are the same three ways variables are returned in a function

+ *By Value* - Returns a copy of the object

  ```cpp
  int foo() {
      int x = 5;
      return x;
  }
  ```

  In the example above, `x` is returned as a copy of the original `x` variable

+ *By Reference* - Returns a reference (alias) to an existing variable, but doesn't refer to a local variable that goes out of scope!

  ```cpp
  int& foo(int& x) {
      return x;
  }
  ```

  In the example above, `x` is simply returned as a reference to an existing variable. Be careful! Referencing a local variable that goes out of scope can lead to undefined behaviors!

+ *By Pointer* - Returns a pointer to an object (can be null). The caller can modify the object via the pointer

  ```cpp
  int* foo(int* x) {
      return x;
  }
  ```

  In the example above, `x` is simply returned as a pointer to an existing variable. Be careful! Like references, pointing to a local variable that goes out of scope can lead to undefined behaviors!

== Copy Semantics

*Copy Semantics* refers to how objects are copied when they are passed as arguments to functions, returned from functions, or assigned to other objects. Copy semantics dictate the rules for creating new objects that are copies of existing ones. Simply speaking, they *define* how objects are copied

A *copy constructor* is used to initialize an object with an existing object of the same type. After the copy constructor executes, the newly created object becomes a copy of the object passed in the initializer

- *Implicit Copy Constructor* - If a copy constructor is not provided for a class, the compiler will create a public *implicit copy constructor* for you

An explicit copy constructor can also be created, by taking in an referenced object type of that class

```cpp
class Foo {
    public:
    Foo() = default;
    Foo(const Foo& foo) {

    }
};
```

where `Foo a; Foo b = a;` implicitly calls the copy constructor on `b`. Declaring any constructor, including a copy constructor, stops the compiler from generating the implicit default constructor, which is why `Foo() = default;` is needed for `Foo a;` to compile.

=== Shallow and Deep Copies

*Shallow* and *deep* copies define how objects are copied!

A *shallow copy* occurs where an object's *pointers* are copied, but *not* *the data they point to*
- Both the object and the copied object share the same underlying data, which means that changing one pointer affects both objects
- If one object deletes or modifies the pointer, the other may be left with invalid data, causing crashes and segmentation faults resulting in undefined behavior or unexpected data, which may contain varied data than what was ideal

A *deep copy* is a completely independent copy of all data, including an object's pointers and the memory they point to
- Unlike a shallow copy, the object and the copied object *do not share the same data*
- Instead, the copied object *allocates new memory* and copies the actual data, so they're fully independent

You can spot the difference in @m0-shallow-deep-copy: with a shallow copy, `a` and `b` point to the same 42, but with a deep copy each one gets its own 42

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    memory(stack: (a: "->h", b: "->h"), heap: (h: 42)), memory(stack: (a: "->h1", b: "->h2"), heap: (h1: 42, h2: 42)),
    [Shallow copy], [Deep copy],
  ),
  caption: [Example: `a` and `b` are the `data` pointers of two objects after `Foo b = a;`],
) <m0-shallow-deep-copy>

=== Copy Assignment Operator

The Copy Assignment Operator can be overloaded to define copy semantics *after* objects have been constructed. An example, for a `Foo` that owns a dynamically allocated `int* data` and an `int size`, looks like such code below

However, multiple checks that are typically implemented include

- Self assignment check (`this != &other`) to ensure that an object is not copying itself!
- Frees or cleans up resources that the current object owns
- Deep copies data from the source object
- Returns `*this`, a reference to the current object to allow assignment chaining (recall that `this` is an implicit pointer to the current object in a class)

```cpp
Foo& operator=(const Foo& other) {
    // Self assignment check
    if (this != &other) {
        // Free the resource this object currently owns
        delete data;

        // Deep copy the data from the other object
        data = other.data ? new int(*other.data) : nullptr;
        size = other.size;
    }
    return *this;
}
```

Typically, you need to overload it when
- Your class owns dynamically allocated memory or other resources.
- You want to *avoid shallow copies* that lead to double frees or dangling pointers
- You want to implement *deep copying* semantics

=== Default and Delete on Copy constructors

Just like a regular constructor, we can have the compiler explicitly generate a `default` copy constructor, `Foo(const Foo& foo) = default`
- Note that this will perform a *shallow copy*

`= delete` on a copy constructor will prevent objects of a certain class from being copied

== Move Semantics

*Move semantics* allow the resources owned by one object to be *moved* or *transferred* to another object *without copying* the underlying data. They simply define how objects are moved!

Deep copies can be expensive, especially when objects manage dynamic memory or other expensive resources. Therefore, move semantics come in handy and avoid a deep copy when necessary

- Simply use move semantics when you want to avoid copying expensive resources and instead transfer ownership to another object!

They are defined like copy semantics, including a *move constructor* and *move assignment operator*

=== rvalue references

An rvalue is a temporary object or value that *does not* have a persistent memory address. This is the opposite of an lvalue, which has a persistent memory address

`int x = 1`

In the code snippet above, `x` is an lvalue (left value) because it is stored in memory with a persistent memory address
- Recall that a pointer will store this memory address and an lvalue reference - sometimes simply called a reference - is a reference or alias to an existing value in memory

In contrast, `1` is an rvalue. It is a temporary value used to initialize `x`

*rvalue references* (right-value references) are references that bind to *rvalues*, temporary objects or literals that are about to expire. They enable *move semantics* by allowing the program to *take ownership* of resources from these temporary objects, avoiding expensive copies

Understanding these make understanding move semantics much more easier because ultimately what happens is the rvalue of one object is being moved to another object via a rvalue reference of the other object

=== Move Constructor

A *move constructor* defines how objects should be moved once initialized

The code below defines a move constructor. Suppose class `Foo` contains two variables `data` and `size` and we want to move it to an rvalue reference called `other`
- `data` is a dynamically allocated int and `size` is an int
- An example of moving the data from `other` to the current object `this` is shown below by using an object's rvalue reference, `other`

```cpp
Foo(Foo&& other) {
    // Move the data of the other object to this object
    this->data = other.data;
    this->size = other.size;

    // Set data pointer to null and size to 0
    other.data = nullptr;
    other.size = 0;
}
```

=== Move Assignment Operator

The *move assignment operator* defines how objects should be moved after being initialized

The code below defines a move assignment operator, but typical operations that are implemented include

- *Self-assignment check* (`this != &other`) - ensures that an object is not moving into itself
- Free or clean up any resources that the current object owns (like deleting dynamically allocated memory)
- *Stealing resources from the source* - transfer the ownership of the resources from the `other` rvalue object to the current object by copying pointers or handles
- *Leave the source in a valid, but empty state* - Set the `other` object pointers or resource handles to `nullptr` or equivalent so that destructor won't free the resources again (double free - free what has already been freed)!
- Return `*this`, a reference to the current object!

```cpp
Foo& operator=(Foo&& other) {
    // Self assignment check
    if (this != &other) {
        // Free the resource this object currently owns
        delete data;

        // Steal the resources from the other object
        data = other.data;
        size = other.size;

        // Leave the other object in a valid, but empty state
        other.data = nullptr;
        other.size = 0;
    }
    return *this;
}
```

`std::move()` will trigger move semantics! For example, in the code below

```cpp
Foo a;
Foo b = std::move(a);
```

`b` is move constructed from `a`, effectively moving `a`'s resources into `b`. Looking at @m0-move-memory, the 42 on the heap never gets copied: `b` just takes over the pointer, and `a` is left with `nullptr`

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    memory(stack: (a: "->h"), heap: (h: 42)), memory(stack: (a: "nullptr", b: "->h"), heap: (h: 42)),
    [Before], [After],
  ),
  caption: [Example: `Foo b = std::move(a);` hands the heap block of `a` to `b` without copying it and leaves `a.data` as `nullptr`],
) <m0-move-memory>

Simply speaking, move semantics are triggered when an object is treated as an rvalue (like the example above), either because it's a temporary (like `b = Foo();`, which move assigns into an existing `b`) or explicitly calling `std::move` (which converts an `lvalue` into an `rvalue`)

== Rule of Zero/Three/Five

When a class manages resources (*dynamic memory*, file handles, etc.), it *must* define how it is *copied*, *moved*, and *destroyed* in order to avoid issues like memory leaks or double deletes

The rule of zero/three/five are rules widely adopted in C++ related to memory/resource management and ownership, specifically about when and how you should define or avoid defining special member functions in a class

*Rule of Zero* - If your class doesn't manage resources directly, *DO NOT* define the *big five*

- Destructor
- Copy Constructor
- Copy Assignment
- Move Constructor
- Move Assignment

*Rule of Three* - If you define one of a *destructor*, *copy constructor*, or *copy assignment operator*, *you should define ALL three of them!*

- This is because handling one implies your class is managing a resource that needs careful copying and cleanup

*Rule of Five* - Applies to modern C++, where if you plan on managing resources with move semantics, define *all 5 of the following* (this is the opposite of the *rule of zero*)
- Destructor
- Copy Constructor
- Copy Assignment
- Move Constructor
- Move Assignment

Use this rule when you need to *avoid deep copying* and allow your class to be efficiently moved
