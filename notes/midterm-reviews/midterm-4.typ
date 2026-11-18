#import "../diagrams.typ": array-cells, graph, tree

#let m4-heap = (4, (5, (15, 16, 25), (9, 14, 12)), (6, (7, 11, none), 20))
#let m4-g-nodes = (u: (0, 1.2), v: (0, 0), w: (1.4, 0.6), z: (2.8, 0.6))

= Midterm 4: Heaps, Disjoint Sets, Iterators, and Graphs

This exam covers priority queues and heaps (modules 19 and 20), disjoint sets (module 21), iterators (module 7), and the first two graph modules, fundamentals and implementations (modules 22 and 23)

== Topics Covered

- Heaps
  - Construction of a Heap
  - Heap runtime
  - HeapifyUp
  - HeapifyDown
  - Array Representation
  - Priority queue ADT
- Disjoint Sets
  - Construction
  - Runtime
  - Union by size and height
- Iterators
- Graphs
  - Graph Fundamentals
  - Graph Implementations

== Heaps

=== Key Ideas

- *Priority queue ADT*: `insert(const T&)`, `removeMin()` (removes and returns the smallest value), and `isEmpty()`. A *min* priority queue is the default. Whatever we store needs a `<`, so pointers and nodes are out
- *Min-heap*: A *complete* binary tree where every node is $<=$ both of its children. The minimum is always the root, and every subtree is a heap too
- A heap is *not* a BST. Siblings and cousins are in no particular order, so you can't search a heap in $O(log n)$
- *Array storage*: Store the tree level by level, with index 0 left empty (or holding the size) so the *root sits at index 1*. For a node at index $i$
  - *Left child*: $2i$
  - *Right child*: $2i + 1$
  - *Parent*: $floor(i / 2)$
  - *Last node*: index $n$, and the leaves are indices $floor(n / 2) + 1$ through $n$
- When the array fills up, double it. That allocates room for exactly one more level

#figure(
  scale(75%, reflow: true, grid(
    columns: 1,
    row-gutter: 1.5em,
    align: center,
    tree(m4-heap),
    array-cells(none, 4, 5, 6, 15, 9, 7, 20, 16, 25, 14, 12, 11, marks: ("parent(2)": 1, "i = 2": 2, "left(2)": 4, "right(2)": 5), highlight: (2,)),
  )),
  caption: [A min-heap and its array, root at index 1. The 5 at index 2 has its parent at index 1 and its children at indices 4 and 5],
) <m4-heap-array>

=== HeapifyUp and HeapifyDown

- *`insert`*: The tree has to stay complete, so the new value goes at index $n + 1$ (`item_[++size_] = key`, growing the array first if it's full). Then *heapify up*: while it's smaller than its parent, swap with the parent. One swap per level, so $O(log n)$
- *`removeMin`*: Save the root, move the *last* value (index $n$) into the root, shrink the size, then *heapify down*: while it's larger than its *smaller* child, swap with that child. Also $O(log n)$
- Swapping with the smaller child is what keeps it correct, since the value moving up is $<=$ both children
- `_isLeaf(i)` is just `2 * i > size_`. In a complete tree, no left child means no right child either

```cpp
template <class T>
void Heap<T>::_heapifyUp(size_t index) {
    if(index > 1) { // the root has no parent
        if(item_[index] < item_[_parent(index)]) {
            std::swap(item_[index], item_[_parent(index)]);
            _heapifyUp(_parent(index));
        }
    }
}

template <class T>
T Heap<T>::_removeMin() {
    T minValue = item_[1];
    item_[1] = item_[size_];
    size_--;
    _heapifyDown(1);
    return minValue;
}

template <class T>
void Heap<T>::_heapifyDown(size_t index) {
    if(!_isLeaf(index)) {
        size_t minChildIndex = _minChild(index);
        if(item_[index] > item_[minChildIndex]) {
            std::swap(item_[index], item_[minChildIndex]);
            _heapifyDown(minChildIndex);
        }
    }
}
```

=== Construction of a Heap

Three ways to turn $n$ values into a heap

+ *Sort the array*: A sorted array already is a heap, but sorting costs $O(n log n)$
+ *Insert $n$ times*: Heapify up indices 2 through $n$, $O(n log n)$
+ *`buildHeap`*: Heapify down from index $floor(n / 2)$ back to 1. This is $O(n)$, and it's the answer when an exam says "build a heap"

Heapify down on a node whose two subtrees are already heaps makes the whole subtree a heap. Leaves are heaps for free, so starting at the last parent and working backwards to the root means both subtrees are always ready

```cpp
template <class T>
void Heap<T>::buildHeap() {
    // leaves are already heaps, so start at the parent of the last node
    for(size_t i = _parent(size_); i > 0; i--) {
        _heapifyDown(i);
    }
}
```

*Why $O(n)$:* in a perfect tree of height $h$ ($n = 2^(h + 1) - 1$), a node heapifies down at most its *height*, and only one node (the root) has height $h$ while half the nodes have height 0. Summing,

$ sum_(k = 0)^h k dot 2^(h - k) = 2^h sum_(k = 0)^h k / 2^k < 2^(h + 1) = n + 1 $

Inserting $n$ times is the opposite: a node heapifies *up* at most its *depth*, and the bottom level alone (about $n / 2$ nodes at depth $h$) costs about $(n / 2) log n$

=== Heap Runtime

#table(
  columns: 2,
  table.header([*Operation*], [*Runtime*]),
  [Peek at the min (the root)], [$O(1)$],
  [`insert` (heapify up)], [$O(log n)$],
  [`removeMin` (heapify down)], [$O(log n)$],
  [Build by sorting, or by inserting $n$ times], [$O(n log n)$],
  [`buildHeap` (heapify down, bottom up)], [$O(n)$],
)

For comparison, as a priority queue an unsorted array or list is $O(1)$ `insert` and $O(n)$ `removeMin`, a sorted one is the reverse, and a balanced BST is $O(log n)$ for both. The heap ties the BST on those two but is smaller (no pointers), faster in practice, and much faster to build

=== Common Mistakes

- Swapping with the *left* child (or whichever child you see first) in heapify down. It has to be the *smaller* child
- Running `buildHeap` forwards from index 1, or starting at $n$ instead of $floor(n / 2)$. Forwards is wrong, and starting at $n$ just wastes time on leaves
- Using the root-at-0 formulas ($2i + 1$, $2i + 2$, $floor((i - 1) / 2)$) when the problem puts the root at index 1
- Treating the heap like a BST, like saying `find` or "find the max" is $O(log n)$

== Disjoint Sets

=== Key Ideas

- A disjoint set keeps a *partition* of the elements $0$ to $n - 1$: every element sits in exactly one set, and each set is named by its *representative*
- `find(k)`: Returns the representative of `k`'s set. Two elements are in the same set exactly when `find(a) == find(b)`
- `union(k1, k2)`: Merges the two sets. Call it on *roots*, so in general `union(find(k1), find(k2))`
- `addElements(num)`: Adds `num` new elements, each alone in its own set
- *Naive array*: Store each element's representative. `find` is $O(1)$, but `union` has to relabel a whole set, $O(n)$

=== Construction (UpTrees)

- One tree per set, every node pointing *up*, and the root is the representative. Trees can have any number of children
- Stored in an array: `data_[k]` is the index of `k`'s parent, and a root stores a *negative* number. A new element starts at $-1$
- Plain `union` is one assignment, `data_[r1] = r2`, which is $O(1)$. `find` walks to the root, so it costs the *height*

#figure(
  scale(80%, reflow: true, grid(
    columns: 1,
    row-gutter: 1em,
    align: center,
    grid(
      columns: 3,
      column-gutter: 3em,
      align: top,
      tree((4, (1, 0))),
      tree((2, 7)),
      tree((5, 3, 6)),
    ),
    array-cells(1, 4, -1, 5, -1, -1, 5, 2, highlight: (2, 4, 5)),
  )),
  caption: [Three uptrees holding $\{0, 1, 4\}$, $\{2, 7\}$, $\{3, 5, 6\}$. Each index holds its parent, and the highlighted roots hold $-1$],
) <m4-uptrees>

=== Union by Size and Height

Without a rule, `union(0, 1)`, `union(1, 2)`, `union(2, 3)`, ... builds a straight line and `find(0)` is $O(n)$. *Smart union* picks which root goes on top

- *Union by size*: The root of the set with *fewer nodes* points at the bigger one. The root stores $-"size"$, and the new root stores the sum
- *Union by height*: The root of the *shorter* tree points at the taller one. The root stores $-("height" + 1)$, because $-0$ would read as "my parent is 0". The height only grows, by 1, when the two heights tie
- Either way the *more negative* root wins, and `find` now checks `data_[k] < 0`
- The two rules can disagree: a tall skinny set against a short wide one goes one way by size and the other way by height
- *Both keep $h <= log n$* since a tree of height $h$ has at least $2^h$ nodes. For height, a tree only reaches height $k$ by linking two trees of height $k - 1$, each with $>= 2^(k - 1)$ nodes. For size, hanging $S$ under a root with at least as many nodes either keeps the height or makes it $h(S) + 1$ with $>= 2 dot 2^(h(S))$ nodes
- *Path compression*: On the way back out of `find`, point every node on the path straight at the root. With it, union by height becomes *union by rank* (same code, but the stored rank never shrinks)

```cpp
int DisjointSets::find(int k) {
    if(data_[k] < 0) { return k; } // a root
    data_[k] = find(data_[k]);     // path compression
    return data_[k];
}

void DisjointSets::unionBySize(int r1, int r2) {
    int newSize = data_[r1] + data_[r2];
    if(data_[r1] < data_[r2]) { // r1 is the bigger set
        data_[r2] = r1;
        data_[r1] = newSize;
    } else {
        data_[r1] = r2;
        data_[r2] = newSize;
    }
}

void DisjointSets::unionByHeight(int r1, int r2) {
    if(data_[r1] < data_[r2]) {
        data_[r2] = r1;
    } else if(data_[r1] > data_[r2]) {
        data_[r1] = r2;
    } else {
        data_[r1] = r2;
        data_[r2]--; // tie: the tree gets one taller
    }
}
```


=== Runtime

#table(
  columns: 3,
  table.header([*Implementation*], [*`find`*], [*`union`*]),
  [Array of representatives], [$O(1)$], [$O(n)$],
  [UpTrees], [$O(n)$], [$O(1)$],
  [UpTrees + smart union], [$O(log n)$], [$O(1)$],
  [UpTrees + smart union + path compression], [amortized $O(alpha(m, n))$], [amortized $O(alpha(m, n))$],
)

- $m$ operations with smart union and path compression take $O(m log^* n)$, and the tighter proven bound is $O(m dot alpha(m, n))$
- $log^* n$ counts how many times you take $log$ to get down to 1, and $alpha$ (inverse Ackermann) grows even slower, at most about 4 for any real input. Treat it as effectively constant, but it's *amortized*, so one single `find` can still be slow

=== Common Mistakes

- Calling `union` on two non-roots and just overwriting `data_[k1]`. That drops the rest of `k1`'s path. Always `find` first
- Mixing up the encodings. A height-0 root stores $-1$ under both rules, but a height-2 root stores $-3$, not $-2$
- Reading the negatives backwards: $-5$ is the *bigger* set (or taller tree) compared with $-3$
- Expecting path compression to update the stored height. It doesn't, which is why we call it rank

== Iterators

=== Key Ideas

- An *iterator* walks every element of a container without the caller knowing how it's stored. An `Array` moves with `++index`, a `LinkedList` with `cur = cur->next`
- A container provides `begin()` (the first element) and `end()` (*one past* the last element). `end()` is never dereferenced, and searches like `find` return it to mean "not found"
- The iterator class (base `std::iterator`) needs at least `operator*` (the data), `operator++` (advance), and `operator!=` (compare with another iterator, taking a `const Iterator&`)
- `operator->` is nice to have but *not required*

#table(
  columns: 3,
  table.header([*Data Structure*], [*`::begin`*], [*`::end`*]),
  [`LinkedList`], [`Iterator(head_)`], [`Iterator(nullptr)`],
  [`Array`], [`Iterator(0)`], [`Iterator(size)`],
)

=== Code You Should Be Able to Write

```cpp
std::vector<Animal> zoo;

// manual iterator loop
for(auto it = zoo.begin(); it != zoo.end(); ++it) {
    std::cout << (*it).name << " " << (*it).food << std::endl;
}

// range-based for loop, which calls begin, end, *, ++, and != for us
for(const Animal& animal : zoo) {
    std::cout << animal.name << " " << animal.food << std::endl;
}
```

=== Common Mistakes

- Looping with `it <= end()` or dereferencing `end()`. The loop condition is `it != end()`
- Writing `it++` for a minimal iterator. Post-increment copies the iterator and returns the old copy, so `++it` is the one to implement and use
- Using `->` on the loop variable in a range-based loop. It's the element itself, so use `.`
- Assuming `operator->` exists. Use `(*it).name` unless you know it's implemented

== Graphs

=== Graph Fundamentals

- $G = (V, E)$, with $n = |V|$ vertices and $m = |E|$ edges
- *Incident edges* $I(v)$ - The edges touching $v$. *Degree* $deg(v) = |I(v)|$. *Adjacent vertices* $A(v)$ - The vertices one edge away from $v$
- *Path*: A sequence of vertices joined by edges. In this class a path *may* repeat vertices. A *simple path* never does
- *Cycle*: A path of at least three vertices that starts and ends at the same vertex, with no other repeats
- *Simple graph*: No self-loops and at most one edge per pair. Assume simple unless told otherwise
- *Subgraph*: $V' subset.eq V$, $E' subset.eq E$, and both ends of every edge in $E'$ are in $V'$
- *Complete*: Every vertex joined to every other. *Connected*: A path between every pair. *Acyclic*: No cycles
- *Connected component*: A connected subgraph that can't be made any bigger. A smaller connected piece inside one doesn't count
- *Spanning tree*: Connected, acyclic, and touching *every* vertex. It has exactly $n - 1$ edges, and only a connected graph has one
- *Handshaking Theorem*: $sum_(v in V) deg(v) = 2m$, since each edge adds 1 to the degree of each end. Visiting every vertex's neighbors costs this sum, which is where most graph runtimes come from

#table(
  columns: 2,
  table.header([*Graph*], [*Number of edges*]),
  [Minimum, not connected], [$0$],
  [Minimum, connected], [$n - 1$ (a tree)],
  [Maximum, simple], [$n(n - 1) / 2$ (complete graph)],
  [Maximum, not simple], [No limit],
)

=== Graph Implementations

The ADT has `insertVertex`, `removeVertex`, `insertEdge`, `removeEdge`, `incidentEdges(v)`, `areAdjacent(v1, v2)`, and `origin(e)` / `destination(e)` for directed graphs. Vertices are numbered $0$ to $n - 1$, so reaching a vertex is $O(1)$

#figure(
  graph(m4-g-nodes, ("u-v:a", "u-w:b", "v-w:c", "w-z:d")),
  caption: [A graph with vertices $u, v, w, z$ (numbered 0 to 3) and edges $a, b, c, d$],
) <m4-impl-graph>

- *Edge list*: A vector of vertices plus a linked list of edges, each edge storing both endpoints. Inserting is $O(1)$, but any lookup scans all $m$ edges. Removed vertices are tombstoned instead of shifting the vector. It's the go-to *file format*. For @m4-impl-graph the edges are $a = (0, 1)$, $b = (0, 2)$, $c = (1, 2)$, $d = (2, 3)$
- *Adjacency matrix*: The edge list plus an $n times n$ matrix whose entry $(i, j)$ is a *pointer* to that edge or `nullptr` (undirected graphs only need $i < j$). `areAdjacent` and `removeEdge` are $O(1)$, `incidentEdges` scans a row in $O(n)$, adding or removing a vertex is $O(n)$ with doubling. $O(n^2)$ space, so it's best when the vertex set doesn't change
- *Adjacency list*: The edge list plus a *doubly linked* list of incident edges per vertex, with each edge pointing back into both lists. For @m4-impl-graph, $u: a, b$, $v: a, c$, $w: b, c, d$, $z: d$. `incidentEdges` is $O(deg(v))$, which is optimal. `areAdjacent` scans the *shorter* list, $O(min(deg(v_1), deg(v_2)))$. This is the default for graph algorithms

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

=== Common Mistakes

- Saying the adjacency list's `removeEdge(v1, v2)` is $O(1)$ when you only have the endpoints. $O(1)$ assumes you already hold the edge, otherwise you first spend $O(min(deg(v_1), deg(v_2)))$ finding it
- Saying matrix `incidentEdges` is $O(deg(v))$. It's $O(n)$ no matter how few edges $v$ has
- Calling any connected chunk a "connected component". It has to be maximal
- Forgetting that a cycle needs at least three vertices and that a "path" here is allowed to repeat vertices

== Practice Problems

*1. (HeapifyUp)* The min-heap array, root at index 1, is $[3, 7, 4, 12, 9, 6, 10]$. Show the array after `insert(2)`

*Answer:* 2 goes at index 8, under index 4 (12). $2 < 12$, swap, now at index 4. Parent is index 2 (7), $2 < 7$, swap. Parent is index 1 (3), $2 < 3$, swap. It's the root, so stop. Result: $[2, 3, 4, 7, 9, 6, 10, 12]$

*2. (HeapifyDown)* Starting again from $[3, 7, 4, 12, 9, 6, 10]$, call `removeMin`. What is returned, and what is the array?

*Answer:* It returns 3. The last value, 10, moves to the root and the size drops to 6: $[10, 7, 4, 12, 9, 6]$. The children are 7 and 4, the smaller is 4, $10 > 4$, swap: $[4, 7, 10, 12, 9, 6]$. At index 3 the only child is index 6 (6), $10 > 6$, swap: $[4, 7, 6, 12, 9, 10]$. Index 6 is a leaf. Final: $[4, 7, 6, 12, 9, 10]$

*3. (buildHeap)* Run `buildHeap` on $[9, 4, 8, 1, 6, 2, 7]$ (root at index 1). Show the array after each heapify down call and count the swaps

*Answer:* $n = 7$, so start at $floor(7 / 2) = 3$
- Index 3 (8): children 2 and 7, swap with 2 $=> [9, 4, 2, 1, 6, 8, 7]$
- Index 2 (4): children 1 and 6, swap with 1 $=> [9, 1, 2, 4, 6, 8, 7]$. Index 4 is a leaf
- Index 1 (9): children 1 and 2, swap with 1 $=> [1, 9, 2, 4, 6, 8, 7]$. Then children 4 and 6, swap with 4 $=> [1, 4, 2, 9, 6, 8, 7]$

Final heap $[1, 4, 2, 9, 6, 8, 7]$ after 4 swaps

*4. (Array representation)* A heap with root at index 1 holds $n = 20$ values. What is the parent of index 13? The children of index 9 and of index 10? Which indices are leaves?

*Answer:* Parent of 13 is $floor(13 / 2) = 6$. Index 9 has children 18 and 19. Index 10 has a left child at 20, but its right child, 21, is past $n$, so it has only one child. The leaves are indices $floor(20 / 2) + 1 = 11$ through 20 (10 leaves)

*5. (True or false)* Justify each, assuming distinct values
- (a) An array sorted in increasing order (from index 1) is a min-heap
- (b) The array of a min-heap is always sorted
- (c) The largest value in a min-heap is always a leaf

*Answer:* (a) True. Every child has a larger index than its parent, so in a sorted array it's at least as large. (b) False, for example $[1, 3, 2]$ is a valid heap. (c) True. An internal node has a child, and that child has to be larger, so an internal node can't be the max

*6. (Runtime)* What's the runtime of finding the *maximum* in a min-heap of $n$ values? And of building a heap by calling `insert` $n$ times versus calling `buildHeap`?

*Answer:* Finding the max is $O(n)$. It's a leaf (problem 5c), but there are about $n / 2$ leaves and nothing orders them, so we check them all. Inserting $n$ times is $O(n log n)$, since about half the nodes can heapify up the full depth $log n$. `buildHeap` is $O(n)$, since most nodes are near the bottom and only heapify down their small height

*7. (Disjoint sets trace)* Elements 0 through 7 start at $-1$. Using `unionBySize` from the notes (on a tie, `r1` points at `r2`), where `union(a, b)` means `unionBySize(find(a), find(b))`, run `union(0, 1)`, `union(2, 3)`, `union(1, 3)`, `union(4, 5)`, `union(5, 3)`, then `find(0)` and `find(4)` with path compression. Give the final array

*Answer:*
- `union(0, 1)`: tie, so `data[0] = 1`, `data[1] = -2`
- `union(2, 3)`: tie, so `data[2] = 3`, `data[3] = -2`
- `union(1, 3)`: both roots, tie, so `data[1] = 3`, `data[3] = -4`
- `union(4, 5)`: tie, so `data[4] = 5`, `data[5] = -2`
- `union(5, 3)`: $-2$ vs $-4$, so 3 is bigger, `data[5] = 3`, `data[3] = -6`
- `find(0)`: path $0 -> 1 -> 3$, so `data[0] = 3` (1 already points at 3)
- `find(4)`: path $4 -> 5 -> 3$, so `data[4] = 3`

Final: $[3, 3, 3, -6, 3, 3, -1, -1]$. Elements 6 and 7 are still alone

*8. (Union by height)* Roots $A$ and $B$ both store $-3$. What height is each tree? What do $A$ and $B$ store after `unionByHeight(A, B)`, and what's the new height?

*Answer:* $-3 = -(h + 1)$, so each has height 2. It's a tie, so `data[A] = B` and `data[B]` drops to $-4$. The new tree has height 3

*9. (Proof)* Show that with union by height, an uptree of height $h$ has at least $2^h$ nodes, and conclude `find` is $O(log n)$

*Answer:* Induction on $h$. Base case: a height 0 tree is one node, and $1 >= 2^0$. Inductive step: union by height only makes a taller tree when both trees have the same height, so a tree of height $k$ came from linking two trees of height $k - 1$. Each of those has $>= 2^(k - 1)$ nodes by the IH, so the merged tree has at least $2 dot 2^(k - 1) = 2^k$. So $n >= 2^h$, meaning $h <= log n$. `find` costs the height, so it's $O(log n)$

*10. (Iterators)* What's wrong with this loop, and what's the fix?

```cpp
for(auto it = v.begin(); it <= v.end(); it++) {
    std::cout << *it << std::endl;
}
```

*Answer:* When `it` equals `v.end()` the condition is still true, so `*it` dereferences one past the last element. Iterators are compared with `!=` (only `!=` is required, `<=` may not even exist), and `++it` is preferred: `for(auto it = v.begin(); it != v.end(); ++it)`

*11. (Handshaking)* (a) Can a simple graph have vertex degrees 3, 3, 3? (b) A simple graph has degrees 4, 3, 3, 2, 2. How many edges does it have? (c) What are the fewest and most edges a connected simple graph on 10 vertices can have?

*Answer:* (a) No. The degree sum is 9, but it must equal $2m$, which is even. (b) $4 + 3 + 3 + 2 + 2 = 14 = 2m$, so $m = 7$. (c) At least $n - 1 = 9$ (a spanning tree), at most $10 dot 9 / 2 = 45$ (complete)

*12. (Implementations)* For @m4-impl-graph, how much work does `areAdjacent(u, z)` take in an adjacency list? Then, what does calling `incidentEdges` on *every* vertex cost in each implementation?

*Answer:* $deg(u) = 2$ and $deg(z) = 1$, so we scan $z$'s list (one entry, $d$) and find no edge to $u$, $O(min(2, 1))$. For every vertex: edge list is $n$ scans of $O(m)$, so $O(n m)$. Matrix is $n$ rows of $O(n)$, so $O(n^2)$. Adjacency list is $sum_v O(deg(v))$ plus $O(1)$ per vertex, which by handshaking is $O(n + m)$
