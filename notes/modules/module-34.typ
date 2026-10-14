#import "../diagrams.typ": tree

= Wrapping up CS 225!

This last chapter is a tour back through the whole course: the C++ ideas we leaned on, and every data structure and algorithm we built, with how they compare. It's a good place to start reviewing for the final

== C++ as a Vehicle

This course is *in* C++, but it isn't *about* C++. We chose C++ because it puts two ideas front and center that matter for data structures in any language

- *Templates* separate the *kind of data* from the *data structure* that stores it, which is exactly how we want to think about data structures. Almost every MP abstracted the stored type with templates
- *Memory management* is fundamental to how a data structure performs, and C++ makes us handle it ourselves. Almost every assignment had tests checking that memory was handled correctly

=== Iterators

Iterators are how we access a data structure without knowing how it's built. An iterator needs

- `operator++` (pre-increment) to move to the next element
- `operator*` to access the current element
- `operator!=` to compare against another iterator

and the data structure provides `begin()` and `end()`. The thing that catches people the most is that *`end()` is one past the last element*, not the last element itself (like in @iterator-array-begin-end). It's unintuitive until you get used to it, but it matches how C-style loops were always written

=== Functions as Data

A *lambda* defines a function inline, usually stored in a variable of type `auto`. It has three parts: the *capture* (variables from the surrounding code it can use), the *parameters*, and the *body*. A common use is a custom comparator, like turning `std::priority_queue` (which is a *max*-heap by default) into a min-heap

```cpp
auto greater = [](int a, int b) { return a > b; };
std::priority_queue<int, std::vector<int>, decltype(greater)> pq(greater);

int threshold = 5;
auto isBig = [threshold](int x) { return x > threshold; }; // captures threshold
```

A *function pointer* is just the address of a function's code in memory. A function's name *is* that address, which makes sense: to call a function, the compiler inserts a call to that location. The syntax for declaring a function pointer type is weird, but with `auto` it's easy to use one

```cpp
int max(int x, int y) {
    return x > y ? x : y;
}

auto myMax = max;   // myMax points to max
int result = myMax(4, 7); // calls max, so result is 7
```

That's how a hash table can store its hash function, for example: as a function pointer it calls whenever it needs a hash

== Lists

Lists come in two flavors, *linked* and *array*, each sorted or unsorted

#table(
  columns: 3,
  table.header([*Operation*], [*Linked list*], [*Array list*]),
  [Access by index], [$O(n)$], [$O(1)$],
  [Insert or remove given a pointer to the spot], [$O(1)$], [$O(n)$],
  [Insert or remove at an index], [$O(n)$ to get there, $O(1)$ to change], [$O(1)$ to get there, $O(n)$ to shift],
  [Search for a value], [$O(n)$], [$O(n)$, or $O(log n)$ with binary search if sorted],
)

An array is just a mathematical offset from its start, so indexing is $O(1)$, but keeping it contiguous makes inserting and removing $O(n)$. A linked list is the opposite. Each one plays to the other's weakness: either it takes time to *find* the spot, or it takes time to *do* the change. Whenever we need an array to grow, we *double* it, for amortized $O(1)$ inserts (see @amortized-doubling)

=== Stacks and Queues

- *Stack* - Last in, first out (LIFO). Every operation is $O(1)$ with a linked list, and amortized $O(1)$ with an array
- *Queue* - First in, first out (FIFO). Also $O(1)$ (amortized for an array). With an array, the natural implementation is a *circular queue* (like in @queue-circular-wrap)

A circular buffer between two pieces of a program that run at different or uneven speeds is one of the most common data structures in real code. It can even be built in hardware for incredibly fast performance

== Trees

We spent almost half of the course on trees, and we've still only scratched the surface. Some things to remember

- An *empty* tree is a perfectly good tree, with height $-1$. Most theory courses skip it, but data structures start out empty
- Our trees are almost always *rooted* (we need a place to attach the data structure) and *binary* (it's good enough, and much less complicated)

*Traversals* visit everything in the tree. *Pre-order*, *in-order*, and *post-order* are all recursive, and only differ in whether we visit a node the first, middle, or last time we reach it. They're all like depth-first search. *Level order* visits everything at distance 0 from the root, then 1, then 2, which is breadth-first search. Written the general way, the only difference between the two is a *stack* versus a *queue*

=== Trees as Dictionaries

#table(
  columns: 3,
  table.header([*Tree*], [*`find` / `insert` / `remove`*], [*Notes*]),
  [BST], [$O(h)$, which is $O(n)$ in the worst case], [An in-order traversal gives the keys in sorted order],
  [AVL tree (BBST)], [$O(log n)$], [Rotations keep it balanced],
  [B-tree of order $m$], [$O(log_m n)$ seeks], [Each node holds up to $m - 1$ keys],
)

A plain BST is only as good as its height, and a tree with only right children is perfectly legal. An AVL tree uses rotations to keep itself balanced, which is like pretending the keys were inserted in a better order. A B-tree makes the base of the log bigger, so the tree is very short (@btree-shorter), which matters when following a pointer is slow, like on a disk or over a network (a disk is roughly a million times slower than cache, and a network can be tens to hundreds of millions of instructions)

That idea goes way beyond B-trees: lots of performance models say "if it's smaller than $X$, it's basically free, and if it's bigger, it's slow". If we can reduce how often we go outside of that small, fast space, we make a huge impact

=== Special Trees

- *KD trees* - Every balanced BST can do approximate searches: if a key isn't in the tree, the nearest key is its in-order predecessor or successor, and we can find every key in a range efficiently. A KD tree does this in $k$ dimensions by splitting the data evenly in a different dimension at every level (@kd-tree-build)
- *Huffman trees* - If we know how often each character appears (either predicted, like for English, or counted from the data), we can build a binary tree with the *least* frequent characters deepest. Each character's code is its path from the root (left is 0, right is 1), which is the most efficient way to encode the data, so it's used for *compression*. In @huffman-tree, the frequent `A` gets a 1-bit code, so the 12 characters take 21 bits instead of 24 with fixed 2-bit codes
- *Heaps* - A complete tree, usually stored as an array (@pq-heap-array), that implements a *priority queue*. `insert` adds at the bottom and heapifies up, and `removeMin` swaps the last value to the root and heapifies down. Theoreticians all say a min-heap is the default, but `std::priority_queue` is a max-heap by default
- *Disjoint sets* - A forest of uptrees supporting add, `union`, and `find`. With smart union and path compression (@ds-path-compression), operations are amortized $O(alpha(m, n))$: the inverse Ackermann function, which is single digits for anything that could fit in the universe, so effectively constant

#figure(
  tree((12, "A:6", (6, "B:3", ("3", "C:2", "D:1")))),
  caption: [Example: a Huffman tree for `A` (6 times), `B` (3), `C` (2), and `D` (1). The codes are `A` = 0, `B` = 10, `C` = 110, `D` = 111],
) <huffman-tree>

== Graphs

There are three ways to represent a graph

- *Edge list* - Super simple, with no overhead for saving or loading, so it's the standard file format, but slow for almost everything else
- *Adjacency matrix* - Easy to write, with $O(1)$ `areAdjacent`, but it uses $O(n^2)$ space and usually isn't the best choice. It shows up a lot because it takes no time to think about
- *Adjacency list* - Pointers everywhere, so it's harder to code, but it's essentially optimal for everything except `areAdjacent`, and it matches how almost every real graph algorithm works

=== Traversals

BFS and DFS on a graph work like they do on a tree, except we *don't visit a vertex twice*. Watch out for one optimization: in BFS, the first time a vertex goes into the queue is when it will be visited, so we can mark it as visited as soon as we *see* it. That works great for BFS, but if you switch the queue to a stack, it breaks DFS, since in DFS a vertex we've seen might be reached by another path before we get to it

=== Graph Algorithms

- *Kruskal's algorithm* (minimum spanning tree) - Put every edge in a priority queue by weight and every vertex in its own disjoint set. Repeatedly take the cheapest edge, and if it connects two different sets, keep it and union them, until we have $n - 1$ edges
- *Prim's algorithm* (minimum spanning tree) - Start from one vertex and repeatedly add the cheapest edge from the tree to a vertex not yet in it, until every vertex is reached
- *Dijkstra's algorithm* (shortest paths from one vertex to all others) - Exactly like Prim's, except the cost of reaching a new vertex is the cost to get to the vertex we're coming from *plus* the edge. Since that's the only change, the analysis is the same as Prim's
- *Floyd-Warshall* (shortest paths between all pairs) - A dynamic programming algorithm: first the shortest paths using no intermediate vertices, then allowing one more vertex at a time. The code is just a triple nested loop, so it's $O(n^3)$

Kruskal's and Prim's runtimes look different on paper, but for connected graphs both come out to $O(m log n)$ with a binary heap, and analyzing them on sparse versus dense graphs shows they're about the same. There's no clear winner, though Prim's leads directly into Dijkstra's

== Hashing

Hashing is really cool, but it has requirements and downsides

- *A good hash function.* For our analysis, it has to satisfy *SUHA*, the simple uniform hashing assumption: the chance that any particular key hashes to any particular slot is exactly $1 / N$, where $N$ is the number of slots. The only real way to get that is to pick the hash function at random from a family of hash functions. That one fact is the trick behind all of our analysis. In practice, hash functions often aren't truly uniform, which is why hash tables usually perform great but sometimes perform terribly
- *Storage*, which is an array
- *A way to handle collisions.* The universe of keys is bigger than the number of slots, so collisions will happen
  - *Separate chaining* (open hashing) stores a list at every slot
  - *Probing* (closed hashing, or open addressing) stores everything inside the table, and on a collision goes somewhere farther down: the next empty slot (*linear probing*), or a step size from a second hash function (*double hashing*). Closed hashing also needs to tell whether a slot is empty *now* versus whether it was *ever* used, since a `find` has to keep probing past slots that used to be full

Altogether, a hash table gets *expected amortized $O(1)$* `insert` and `find` with $O(n)$ space for $n$ items. With separate chaining, `insert` is actually $O(1)$ (just add to the front of the list), but `find` and `remove` can be $O(n)$ in the worst case

#table(
  columns: 3,
  table.header([*Dictionary*], [*`find`*], [*`insert`*]),
  [Hash table], [expected $O(1)$], [expected amortized $O(1)$],
  [AVL tree], [$O(log n)$], [$O(log n)$],
  [Sorted array], [$O(log n)$], [$O(n)$],
  [Unsorted list], [$O(n)$], [$O(1)$],
)

The big takeaway: hash tables are really useful, but for a *specific* problem, there's usually a better solution, because we usually know something about the data that lets us organize it more efficiently. Think of a hash table as "I don't have a good solution yet, so let's put this here for now". If nothing better exists, hash tables are pretty good, but sometimes they'll slow down (when rehashing, or when the hash function turns out to be bad)

== Bloom Filters

A bloom filter is a hash table that *doesn't store the data*: just a bit vector of $m$ bits, with one hash function or $k$ of them. Inserting sets the hashed bits to 1, and a lookup checks whether all of them are 1. Both take $O(1)$ time, every time, not just in expectation

Of the four possible outcomes, only three can happen

#table(
  columns: 3,
  table.header([], [*Filter says yes*], [*Filter says no*]),
  [*Was inserted*], [True positive], [Can't happen],
  [*Wasn't inserted*], [False positive], [True negative],
)

So a bloom filter is very small and very fast, as long as we're okay with *sometimes* saying yes when the answer is no. "Is this in the cache?" is a great use: a false positive just means a cache miss, which isn't a big deal. "Is this safe to touch?" would be a terrible one

The false positive rate goes up as we insert more items, and there's a best number of hash functions $k$ for a given size: too few and each item sets too few bits, too many and the bit vector fills up. Finding that sweet spot takes work and isn't always practical. Bloom filters also can't *delete* (clearing a bit might erase another item) and can't *resize* (we don't have the original items to rehash)

== Sketching: Cardinality and Similarity

*Cardinality* asks how many *unique* items there are. Counting all the items is easy, but telling whether an item is unique means checking whether we've seen it before, which means storing everything. With data sets of 60 billion to 130 trillion items, that's impossible

Instead, we hash every item to a number between 0 and 1 (divide the hash by the largest possible hash value) and only keep the *minimum*. If $n$ unique items hash uniformly, the minimum is expected to be about $1 / (n + 1)$, so if the smallest value we saw was 0.095, we'd estimate $n approx 1 / 0.095 - 1 approx 9.5$. Keeping the $k$ smallest values instead of just one makes the estimate much more reliable: the $k$-th smallest is about $k / (n + 1)$

The same $k$ smallest values let us estimate *similarity*: comparing two sets through their unions and intersections (Jaccard similarity) using only the $k$ items we stored. We didn't analyze the accuracy, since that probability is beyond this course (and leans even harder on SUHA), but with just $k$ values per set we get reasonably accurate predictions

== The Final Exam

- *Coding (about half the points).* Expect around three coding questions
  - One will be *recursion on trees*: build a tree with BST inserts or some kind of splitting, compute heights or count leaves, mirror a tree, and so on. These follow the usual recursive pattern; they won't need a clever or non-obvious algorithm, just comfort with recursion
  - The others will be straightforward C++ on data structures we've built, like a single AVL rotation in an otherwise complete AVL tree, some heap operations, some hash table operations, or a bloom filter given its hash functions, possibly followed by using it (like counting words with your hash table). *Not* linked lists, and *not* graphs
- *Multiple choice and short answer.* Everyone will get questions on *sketching* (bloom filters, cardinality, and Jaccard similarity). Beyond that, questions are pulled from pools covering the whole semester, so not everyone sees every topic, but everyone sees a selection of all of them
- *Studying.* The practice exams are the best resource, since the questions are pulled from (or are like) them. The C++ documentation is linked from the exam itself
