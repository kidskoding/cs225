#import "../diagrams.typ": array-cells

= Final Exam: Probabilistic Data Structures

The final exam is comprehensive. Everything from Midterms 0 through 5 is fair game, so the earlier reviews still apply

- *A.0* Midterm 0: prerequisite material (recursion, induction, Big-O, graphs, trees)
- *A.1* Midterm 1: lists
- *A.2* Midterm 2: trees and binary search trees
- *A.3* Midterm 3: trees, BSTs, AVL trees, and BTrees
- *A.4* Midterm 4: heaps, disjoint sets, iterators, and graphs
- *A.5* Midterm 5: graph algorithms, probability, and hashing

This review goes deep on the one new unit, probabilistic data structures (modules 31 to 33). After that comes a one-stop runtime cheat sheet for the whole course, then practice problems

== Topics Covered

The final exam is comprehensive and includes all materials on previous exams as well as the following that was not on any exam.

- Probabilistic Data Structures
  - Bloom Filters
  - Cardinality Estimation
  - Minhash Sketching

All three structures make the same deal: we accept answers that are sometimes a little wrong, and in exchange we store far less than the data. All three also lean on *SUHA*, so every hash acts uniform and independent. If the hash function isn't close to that, none of the error numbers below hold

From the wrap-up chapter: *everyone* gets multiple choice or short answer on sketching (Bloom filters, cardinality, Jaccard similarity), and a coding question could be a Bloom filter given its hash functions

== Bloom Filters

=== Key Ideas

- *Bloom filter*: a hash table that keeps one bit per slot and no keys. It is $m$ bits, all 0 at the start, plus $k$ hash functions that share that one bit vector
- *insert($x$)*: set bits $h_1(x), ..., h_k (x)$ to 1. A bit that is already 1 stays 1
- *find($x$)*: check those same $k$ bits. Any 0 means *definitely not* in the set (stop at the first 0). All 1s means *maybe*
- *One-sided error*: false negatives are impossible, since an inserted key's bits were set and bits never go back to 0. False positives happen when other keys happened to set all $k$ bits
- A true positive and a false positive look identical to the filter. It threw away the keys, so it can't tell them apart
- *Good use*: when a false positive is cheap. Malicious URL check: "no" means safe with zero network traffic, "maybe" costs one request to the real service. Browser cache: cache a resource only on its second visit
- *No remove*: clearing a key's bits can clear bits another key needs, which creates a false negative
- *No resize*: there are no keys left to rehash, so changing $m$ or $k$ means rebuilding from the original data
- *Union*: bitwise or of two filters with the same $m$ and the *same* hash functions is *exactly* the filter of $S_1 union S_2$
- *Intersection*: bitwise and still has no false negatives for $S_1 inter S_2$, but it can keep extra 1s, so it is *not* the same as the filter of $S_1 inter S_2$

The running example from module 31 uses $m = 10$ and

$ h_1(x) = x mod 10 #h(2em) h_2(x) = 2x mod 10 #h(2em) h_3(x) = (3x + 5) mod 10 $

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1.5em,
    align: (right + horizon, left + horizon),
    [Start], array-cells(0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    [Insert 6], array-cells(0, 0, 1, 1, 0, 0, 1, 0, 0, 0, marks: ("h1(6)": 6, "h2(6)": 2, "h3(6)": 3), highlight: (2, 3, 6)),
    [Insert 8], array-cells(0, 0, 1, 1, 0, 0, 1, 0, 1, 1, marks: ("h1(8)": 8, "h2(8)": 6, "h3(8)": 9), highlight: (8, 9)),
    [Insert 4], array-cells(0, 0, 1, 1, 1, 0, 1, 1, 1, 1, marks: ("h1(4)": 4, "h2(4)": 8, "h3(4)": 7), highlight: (4, 7)),
  ),
  caption: [Example: inserting 6, 8, and 4 into a 10-bit filter with $k = 3$. Highlighted cells are the bits that changed. 8 only sets two new bits, since bit 6 was already 1],
) <fe-bloom-insert>

On the finished filter, only bits 0, 1, and 5 are 0

- `find(6)`: bits 6, 2, 3 are all 1, so yes (true positive)
- `find(1)`: bit $h_1(1) = 1$ is 0, so no right away (true negative)
- `find(9)`: bits 9, 8, 2 are all 1, so yes, but 9 was never inserted (false positive). Bit 9 came from $h_3(8)$, which is the cost of sharing one vector between all $k$ functions
- Removing 8 would clear bit 6, and then `find(6)` says no. That's a false negative, which is why there's no remove

=== Formulas

Filter of $m$ bits, $k$ SUHA hash functions, $n$ keys inserted. Count the chance a bit is still *0*, then flip it

- One hash misses a given bit with probability $1 - 1/m$
- All $n$ keys together make $n k$ independent hashes, and every one must miss: $(1 - 1/m)^(n k)$
- A false positive needs all $k$ checked bits to be 1

$ P("false positive") = (1 - (1 - 1/m)^(n k))^k approx (1 - e^(-(n k) / m))^k $

$ k^* = (m / n) ln 2 approx 0.7 dot m / n #h(3em) m = (k n) / (ln 2) #h(3em) n = (m ln 2) / k $

- Bigger $m$ is better, bigger $n$ is worse, and bigger $k$ cuts both ways: each key fills more bits, but a query needs more 1s to be fooled
- At $k^*$, half the bits are 1 and the false positive rate is about $(1/2)^k$. With 10 bits per key, $k^* approx 6.93$, and $k = 7$ gives about 0.82%
- $k^*$ usually isn't a whole number. Plug in the integers on both sides and keep the better one
- Even at the optimum, $m$ is still linear in $n$. A Bloom filter is a big constant-factor saving (a few bits per key), not a change in Big-O. Fix $m$ and $k$ at creation, ideally with an estimate of $n$

=== Runtimes

#table(
  columns: 3,
  table.header([*Operation*], [*Runtime*], [*Notes*]),
  [`insert`], [$O(k)$], [$k$ is fixed, so also $O(1)$, every time (not just expected)],
  [`find` / `contains`], [$O(k)$], [can stop at the first 0],
  [Union (bitwise or)], [$O(m)$], [same $m$ and same hash functions required],
  [Space], [$O(m)$ bits], [does not grow with $n$, but a full filter says yes to everything],
  [`remove`, resize], [not supported], [],
)

=== Code You Should Be Able to Write

Bit $i$ lives in word `i / 64` at position `i % 64`. Shift `uint64_t(1)`, not a plain `1`, which is only 32 bits

```cpp
void insert(int key) {
    for(const HashFunction& h : hashes_) {
        size_t i = h(key) % m_;
        bits_[i / 64] |= uint64_t(1) << (i % 64);
    }
}

bool contains(int key) const {
    for(const HashFunction& h : hashes_) {
        size_t i = h(key) % m_;
        // one 0 means the key was never inserted
        if((bits_[i / 64] & (uint64_t(1) << (i % 64))) == 0) {
            return false;
        }
    }
    return true;
}
```

```cpp
void BloomFilter::unionWith(const BloomFilter& other) {
    for(size_t w = 0; w < bits_.size(); w++) {
        bits_[w] |= other.bits_[w];
    }
}
```

=== Common Mistakes

- Saying a Bloom filter can give a false negative "when it gets full". It never can. A full filter gives false positives on everything
- Reading the false positive formula as $p^k$. That only holds for $k$ *separate* filters. With one shared vector, keys set bits for each other, so it fills faster
- Assuming more hash functions is always better. Past $k^*$ the filter fills up and the rate climbs again
- Calling the bitwise and of two filters "the intersection filter". It works as a filter, but its bits and error rate differ from the real one

== Cardinality Estimation

=== Key Ideas

- *Cardinality*: the number of *unique* items in a set. An exact count means storing everything seen so far, which is impossible for huge streams
- *Cardinality estimate*: a one-pass guess at that count that keeps only a tiny summary of the stream
- *Hat problem*: $n$ values spread uniformly over a range cut it into $n + 1$ gaps of about equal average length. The first gap ends at the minimum, so a small minimum means many values
- *Hashing*: turns real data into uniform values (under SUHA). Divide each hash by the size of the hash range to land in $[0, 1)$
- *Duplicates are free*: a repeated item hashes to the same value, so it can't move the minimum. The minimum depends only on the unique items
- *Expected minimum*: for $n$ uniform values in $[0, 1)$, $E[M] = 1 / (n + 1)$
- *Why*: add one more value $X_(n + 1)$. The chance it lands below $M$ is $E[M]$ (it's uniform), and it is also $1 / (n + 1)$ (each of the $n + 1$ values is equally likely to be smallest)
- *$k$ smallest*: $M_k$, the $k$-th smallest value, marks where gap number $k$ ends, so $E[M_k] = k / (n + 1)$. Averaging $k$ gaps smooths out one lucky hash

$ n approx 1 / M - 1 #h(4em) n approx k / M_k - 1 $

- *Fewer than $k$ values at the end*: the stream had fewer than $k$ unique items, and the sketch size is the exact count
- *Accuracy*: $k = 1$ is typically off by about two thirds, $k = 10$ by about 21%, $k = 100$ by about 6%. Error depends on $k$, *not* on $n$, and the returns shrink: $10 times$ the $k$ gives about $sqrt(10) approx 3 times$ less error

=== Runtimes

#table(
  columns: 4,
  table.header([*Sketch*], [*`insert`*], [*`estimate`*], [*Space*]),
  [Single minimum (one `double`)], [$O(1)$], [$O(1)$], [$O(1)$],
  [$k$ smallest in a `std::set`], [$O(log k)$], [$O(1)$], [$O(k)$],
  [$k$ smallest in a sorted array], [$O(k)$ (shifting)], [$O(1)$], [$O(k)$],
)

We still read every item, so the whole stream is one $O(n)$ pass. The win is space, not time

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Insert 492], array-cells(492, none, none, highlight: (0,)),
    [Insert 253], array-cells(253, 492, none, highlight: (0, 1)),
    [Insert 810], array-cells(253, 492, 810, highlight: (2,)),
    [Insert 327: 810 is dropped], array-cells(253, 327, 492, highlight: (1, 2)),
    [Insert 660: too big], array-cells(253, 327, 492),
  ),
  caption: [Example: a $k = 3$ sketch for hashes (out of 1000) 492, 253, 810, 327, 660. Highlighted cells changed. $M_3 = 0.492$, so the estimate is $3 / 0.492 - 1 approx 5.10$ for 5 unique items. With $k = 1$, it would be $1 / 0.253 - 1 approx 2.95$],
) <fe-kmv-build>

=== Code You Should Be Able to Write

A `std::set` keeps the values sorted (largest at the end) and ignores repeats, which handles duplicate items

```cpp
void CardinalitySketch::insert(const std::string & item) {
    double h = hash_(item) / maxHash_;   // scale into [0, 1]
    smallest_.insert(h);
    // keep only the k smallest by dropping the largest
    if(smallest_.size() > k_) {
        smallest_.erase(std::prev(smallest_.end()));
    }
}

double CardinalitySketch::estimate() const {
    if(smallest_.size() < k_) {
        return smallest_.size();   // fewer than k unique items: exact
    }
    return k_ / *smallest_.rbegin() - 1;
}
```

=== Common Mistakes

- Forgetting to scale the hash into $[0, 1)$ before plugging into $1 / M - 1$
- Using the formula when the sketch has fewer than $k$ values. Then the count is exact
- Thinking a longer stream or more duplicates makes the estimate better. Only $k$ matters
- Forgetting the $- 1$. With $M_k = k / (n + 1)$, solving gives $n = k / M_k - 1$, not $k / M_k$

== MinHash Sketching

=== Key Ideas

- *Jaccard similarity*: $J(A, B) = abs(A inter B) / abs(A union B)$. It is 0 for disjoint sets, 1 for equal sets, and always in $[0, 1]$ with no units. Unlike a raw count of shared items, it also charges for what the sets *don't* share
- *MinHash fact*: under SUHA, every item of $A union B$ is equally likely to have the smallest hash. The two sets have the same minimum hash exactly when that item is shared, so $P(min h(A) = min h(B)) = J(A, B)$
- One minimum is a single coin flip (always 0 or 1), so we keep $k$ samples instead
- *k-min sketch*: the $k$ smallest hash values of a set. It is the same structure as the cardinality sketch, so one pass gives both the set's size and its sketch for similarity
- *Union sketch*: merge the two sorted sketches like merge sort, writing a shared value once, and stop after $k$ values. The result is *exactly* the k-min sketch of $A union B$
- *Membership from sketches*: if a value is below the largest value in $B$'s sketch but not in $B$'s sketch, it is not in $B$. Above $B$'s largest value, we can't tell
- *Intersection sketch*: the values in *both* sketches. It usually has fewer than $k$ values, since a shared item with a large hash never made it into either sketch. It keeps all $k$ only when the two sketches are identical

Three ways to estimate $J$ from two sketches

+ *Shared fraction of the union sketch*: the number of union-sketch values found in both sketches, divided by $k$
+ *Smaller intersection sketch*: treat it as a $k'$-value sketch, estimate $abs(A inter B) approx k' / M_(k') - 1$, then divide by the union estimate. Less accurate, since it uses fewer values
+ *Through the union*: $abs(A inter B) = abs(A) + abs(B) - abs(A union B)$, all three from full $k$ sketches. Subtracting estimates *adds* their errors, so with small $k$ it can even go negative

=== Runtimes

#table(
  columns: 3,
  table.header([*Operation*], [*Runtime*], [*Notes*]),
  [Build a k-min sketch (sorted array)], [$O(k)$ per item], [a new smallest value shifts all $k$],
  [Union sketch (merge)], [$O(k)$], [stop after $k$ values],
  [Intersection sketch], [$O(k)$], [walk both sorted sketches],
  [Estimate $J$ or a cardinality], [$O(k)$ or less], [no access to the original sets],
  [Space per set], [$O(k)$], [hash values only, not items],
)

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Sketch of $A$], array-cells(3, 7, 8, 11, 15, 17, 22, 23, highlight: (0, 1, 3, 5, 7)),
    [Sketch of $B$], array-cells(2, 3, 6, 7, 9, 11, 17, 23, highlight: (1, 3, 5, 7)),
    [Sketch of $A union B$], array-cells(2, 3, 6, 7, 8, 9, 11, 15),
    [Sketch of $A inter B$], array-cells(3, 7, 11, 17, 23),
  ),
  caption: [Example: two $k = 8$ sketches with hashes out of 100. The merge gives the union sketch. The shared values (highlighted) leave an intersection sketch of only 5 values],
) <fe-minhash-merge>

The three estimates for @fe-minhash-merge

- $abs(A union B) approx 8 / 0.15 - 1 approx 52.3$ and $abs(A) approx abs(B) approx 8 / 0.23 - 1 approx 33.8$
- Shared fraction: 3, 7, and 11 of the union's 8 values are shared, so $J approx 3 / 8 = 0.375$
- Intersection sketch: $5 / 0.23 - 1 approx 20.7$, so $J approx 20.7 / 52.3 approx 0.40$
- Through the union: $33.8 + 33.8 - 52.3 = 15.2$, so $J approx 15.2 / 52.3 approx 0.29$

They disagree because $k = 8$ is tiny, so none of the three is reliable on its own

=== Limits

- *Accuracy grows with $k$* with diminishing returns, just like cardinality. In the module's experiment, the shared fraction beat going through the union at every $k$
- *Very different set sizes break it.* If $L$ is much bigger than $S$, the shared items can sit past the end of $L$'s sketch, so the union sketch is all $L$'s values and the overlap is never seen. There's no nice error bound, and it gets worse as the sizes drift apart
- *$k$-partitions*: split the hash range by the most significant bits (`00`, `01`, `10`, `11`) and keep the $k$ smallest in *each* part, so samples spread over the whole range. Compare part by part and combine. An empty part counts as zero similarity for its share. It only helps a little, so compare sets of similar size when you can

=== Common Mistakes

- Taking the $k$ smallest of the *intersection* and expecting $k$ of them. It is usually shorter
- Writing a shared value twice when merging the union sketch
- Concluding a value is not in $B$ just because it isn't in $B$'s sketch, when it is *larger* than everything in $B$'s sketch
- Forgetting that every estimate here assumes SUHA hash functions

== Whole-Course Cheat Sheet

Runtimes as the notes give them. $n$ is the number of items (vertices for graphs), $m$ is edges for graphs, $h$ is tree height, and $\*$ means amortized

=== Lists

#table(
  columns: 3,
  table.header([*Operation*], [*Linked list*], [*Array list*]),
  [Access by index], [$O(n)$], [$O(1)$],
  [Insert or remove at front or back], [$O(1)$], [$O(1)^*$ (doubling)],
  [Insert or remove given a pointer], [$O(1)$], [$O(n)$ (shifting)],
  [Insert or remove at an index], [$O(n)$ to get there], [$O(n)$ to shift],
  [Find a value (unsorted / sorted)], [$O(n)$ / $O(n)$], [$O(n)$ / $O(log n)$],
)

=== Stacks and Queues

#table(
  columns: 3,
  table.header([*Structure*], [*Add (`push` / `enqueue`)*], [*Remove (`pop` / `dequeue`)*]),
  [Stack (LIFO), linked list], [$O(1)$], [$O(1)$],
  [Stack, array], [$O(1)^*$], [$O(1)$],
  [Queue (FIFO), linked list], [$O(1)$], [$O(1)$],
  [Queue, circular array], [$O(1)^*$], [$O(1)$],
)

=== Trees: BST, AVL, BTree

#table(
  columns: 4,
  table.header([*Tree*], [*`find` / `insert` / `remove`*], [*Traverse*], [*Notes*]),
  [BST], [$O(h)$, worst $O(n)$], [$O(n)$], [$O(log n)$ on average over random insert orders. In-order gives sorted keys],
  [AVL tree], [$O(log n)$], [$O(n)$], [height at most about $1.44 log n$. Each rotation is $O(1)$],
  [BTree of order $m$], [$O(log_m n)$ seeks], [$O(n)$], [up to $m - 1$ keys per node, cheap work inside a node],
  [BBST range search], [$O(log n + k)$], [], [$k$ = keys in the answer],
)

=== Heaps and Priority Queues

#table(
  columns: 3,
  table.header([*Implementation*], [*`insert`*], [*`removeMin`*]),
  [Unsorted array or list], [$O(1)$], [$O(n)$],
  [Sorted array or list], [$O(n)$], [$O(1)$],
  [AVL tree], [$O(log n)$], [$O(log n)$],
  [Binary heap], [$O(log n)$ (heapify up)], [$O(log n)$ (heapify down)],
)

- `buildHeap` (heapify down from the last non-leaf back to the root) is $O(n)$. Inserting $n$ times or sorting is $O(n log n)$
- Root at index 1: children at $2i$ and $2i + 1$, parent at $floor(i / 2)$
- `std::priority_queue` is a *max*-heap by default

=== Disjoint Sets

#table(
  columns: 3,
  table.header([*Implementation*], [*`find`*], [*`union`*]),
  [Array of representatives], [$O(1)$], [$O(n)$],
  [UpTrees], [$O(n)$], [$O(1)$],
  [UpTrees + smart union], [$O(log n)$], [$O(1)$],
  [Smart union + path compression], [amortized $O(alpha(m, n))$], [amortized $O(alpha(m, n))$],
)

$alpha$ is the inverse Ackermann function, effectively constant. The bound is amortized, so one `find` can still be slow

=== Graph Implementations

#table(
  columns: 4,
  table.header([*Operation*], [*Edge list*], [*Adjacency matrix*], [*Adjacency list*]),
  [Space], [$O(n + m)$], [$O(n^2)$], [$O(n + m)$],
  [`insertVertex`], [$O(1)$], [$O(n)$], [$O(1)$],
  [`removeVertex`], [$O(m)$], [$O(n)$], [$O(deg(v))$],
  [`insertEdge`], [$O(1)$], [$O(1)$], [$O(1)$],
  [`removeEdge`], [$O(m)$], [$O(1)$], [$O(1)$],
  [`incidentEdges`], [$O(m)$], [$O(n)$], [$O(deg(v))$],
  [`areAdjacent`], [$O(m)$], [$O(1)$], [$O(min(deg(v_1), deg(v_2)))$],
)

=== Graph Algorithms

#table(
  columns: 3,
  table.header([*Algorithm*], [*Setup*], [*Runtime*]),
  [BFS / DFS], [adjacency list], [$O(n + m)$],
  [BFS / DFS], [adjacency matrix], [$O(n^2)$],
  [Kruskal's (MST)], [heap or sorted list + disjoint sets], [$O(m log m) = O(m log n)$],
  [Prim's (MST)], [binary heap + adjacency list], [$O(m log n)$],
  [Prim's], [binary heap + adjacency matrix], [$O(n^2 + m log n)$],
  [Prim's], [unsorted array, either graph], [$O(n^2)$],
  [Prim's / Dijkstra's], [Fibonacci heap + adjacency list], [$O(m + n log n)$],
  [Dijkstra's (single source)], [binary heap + adjacency list], [$O(m log n)$],
  [Dijkstra's], [unsorted array, either graph], [$O(n^2)$],
  [Floyd-Warshall (all pairs)], [distance matrix], [$O(n^3)$ time, $O(n^2)$ space],
)

- On a dense graph ($m approx n^2$), the unsorted array versions win with $O(n^2)$. On a sparse graph, heap + adjacency list wins
- Dijkstra's needs non-negative edges. Floyd-Warshall is $O(n^3)$ whatever the weights

=== Hash Tables

#table(
  columns: 4,
  table.header([*Operation*], [*Hash table*], [*AVL tree*], [*Unsorted linked list*]),
  [`find`], [$O(1)$ expected, worst $O(n)$], [$O(log n)$], [$O(n)$],
  [`insert`], [$O(1)^*$ expected], [$O(log n)$], [$O(1)$],
  [`remove`], [$O(1)$ expected, worst $O(n)$], [$O(log n)$], [$O(n)$],
  [Range find], [No], [Yes], [No],
)

- Load factor $alpha = n / m$ for a table of $m$ slots. Separate chaining `find` is $O(1 + alpha)$ expected, and resizing at a fixed max $alpha$ keeps that $O(1)$
- Separate chaining `insert` is $O(1)$ (front of the chain). Probing (linear or double hashing) stays fast up to roughly 50% to 80% full, then blows up
- Every expected bound assumes SUHA. A hash table never gives a real worst-case guarantee, so if you need one, use a balanced BST

== Practice Problems

Problems 1 to 4 use the module's 10-bit filter with $h_1(x) = x mod 10$, $h_2(x) = 2x mod 10$, $h_3(x) = (3x + 5) mod 10$ where needed

+ *Bloom filter trace.* Start from an empty 10-bit filter and insert 3, then 7. Which bits are 1? Then answer `find(13)`, `find(5)`, and `find(17)`, and say which answers are false positives

  *Answer:* 3 sets bits $3$, $6$, $14 mod 10 = 4$. 7 sets bits $7$, $14 mod 10 = 4$, $26 mod 10 = 6$, so only bit 7 is new. The 1s are bits *3, 4, 6, 7*
  - `find(13)` checks 3, $26 mod 10 = 6$, $44 mod 10 = 4$. All 1, so *yes*, a false positive (13 was never inserted)
  - `find(5)` checks bit 5 first, which is 0, so *no*
  - `find(17)` checks 7, $34 mod 10 = 4$, $56 mod 10 = 6$. All 1, so *yes*, another false positive
  These toy hashes only depend on the last digit, so 13 and 3 (and 17 and 7) always look identical. Real hash functions have to be independent for that not to happen

+ *False positive rate.* A filter has $m = 800$ bits, $k = 3$ hash functions, and $n = 100$ keys. Estimate the false positive rate. What is the optimal $k$, and which whole number would you use?

  *Answer:* $(1 - e^(-(100 dot 3) / 800))^3 = (1 - e^(-0.375))^3 approx (1 - 0.687)^3 = 0.313^3 approx 0.031$, so about *3.1%*. The optimum is $k^* = (800 / 100) ln 2 approx 5.55$. Try both neighbors: $k = 5$ gives $(1 - e^(-0.625))^5 approx 2.17%$ and $k = 6$ gives $(1 - e^(-0.75))^6 approx 2.16%$. They're nearly tied, and *6* is barely better

+ *True or false, with a reason.*
  + Removing a key that was definitely inserted, by clearing its $k$ bits, is safe
  + If a Bloom filter says no, the key is definitely not in the set, even when the filter is nearly full
  + We want 1000 keys at the optimal $k = 7$. We need about 10,100 bits, and the false positive rate will be about 0.8%
  + The bitwise and of two filters (same $m$, same hash functions) equals the filter of $S_1 inter S_2$

  *Answer:*
  + *False.* Another key may share one of those bits. In @fe-bloom-insert, clearing 8's bits clears bit 6, and then `find(6)` says no, a false negative
  + *True.* An inserted key's bits are all 1 forever. Fullness only adds false positives
  + *True.* $m = (k n) / (ln 2) = 7000 / 0.693 approx 10,100$ bits, and at the optimum the rate is about $(1/2)^7 approx 0.78%$
  + *False.* With $S_1 = \{6, 4\}$ and $S_2 = \{8, 4\}$, the and has bit 6 set (from 6 in $S_1$ and from 8 in $S_2$), but the filter of $\{4\}$ only has bits 4, 7, 8. Or is exact for union, and is not exact for intersection

+ *Code.* A browser caches a resource only on its *second* visit. Given the module's `BloomFilter` (with `insert(int)` and `contains(int)`), write `toCache`, which goes through the requested resource ids in order and returns the ones to cache, updating the filter as it goes. What does a false positive cost here?

  *Answer:*
  ```cpp
  std::vector<int> toCache(BloomFilter& seen,
                           const std::vector<int>& requests) {
      std::vector<int> result;
      for(int r : requests) {
          if(seen.contains(r)) {
              result.push_back(r);   // probably the second visit
          } else {
              seen.insert(r);        // definitely the first visit
          }
      }
      return result;
  }
  ```
  This is $O(k)$ per request. A false positive makes us cache something we've only seen once, which is what browsers did for *everything* before the filter, so it's cheap. A false negative would be worse, but it can't happen

+ *Cardinality sketch trace.* A stream's hashes (out of 1000) are 580, 150, 880, 580, 260, 700, 150, 430. How many unique items are there? Build the $k = 3$ sketch step by step, then estimate the cardinality with $k = 1$, $k = 3$, and $k = 8$

  *Answer:* The unique hashes are 150, 260, 430, 580, 700, 880, so *6* unique items. The $k = 3$ sketch
  - 580: [580]. 150: [150, 580]. 880: [150, 580, 880]
  - 580 again: already there, skip
  - 260: [150, 260, 580], dropping 880
  - 700: bigger than 580, ignore. 150 again: skip
  - 430: [150, 260, 430], dropping 580
  Estimates: $k = 1$ gives $1 / 0.15 - 1 approx 5.67$. $k = 3$ gives $3 / 0.43 - 1 approx 5.98$. With $k = 8$, the sketch only ever holds 6 values, fewer than $k$, so the answer is *exactly 6*, no formula needed

+ *Cardinality concepts.*
  + Why does $E[M] = 1 / (n + 1)$?
  + Stream X has 1000 unique items, each repeated 50 times. Stream Y has the same 1000 items once each. With the same hash function and $k$, how do the estimates compare?
  + With $k = 10$ the typical error is about 21%. Roughly what $k$ brings it near 6%?
  + What are the insert time and space of `CardinalitySketch` with a `std::set`?

  *Answer:*
  + Add one more uniform value. The chance it falls below the current minimum is $E[M]$, because it's uniform on $[0, 1)$. It's also $1 / (n + 1)$, because each of the $n + 1$ values is equally likely to be the smallest. Same event, so they're equal
  + *Identical.* Repeats hash to values already in the sketch, so the sketch is exactly the same
  + About $k = 100$. Ten times the $k$ cuts the error by roughly $sqrt(10) approx 3$, which matches the module's table (21% at $k = 10$, 6% at $k = 100$)
  + $O(log k)$ per insert (the set holds at most $k + 1$ values) and $O(k)$ space

+ *Jaccard similarity.* Let $A = \{1, 2, 3, 4, 5, 6\}$ and $B = \{4, 5, 6, 7, 8\}$. Compute $J(A, B)$. Under SUHA, what is the probability that $A$ and $B$ have the same minimum hash, and why?

  *Answer:* $A inter B = \{4, 5, 6\}$ and $A union B = \{1, ..., 8\}$, so $J = 3 / 8 = 0.375$. The probability is also *3/8*. The item with the smallest hash in $A union B$ is equally likely to be any of its 8 items, and the two minimums match exactly when it's one of the 3 shared ones

+ *MinHash estimates.* Two $k = 4$ sketches with hashes out of 100 are $A$: [5, 12, 30, 41] and $B$: [12, 19, 30, 55]. Find the union sketch and the intersection sketch, then estimate $J$ all three ways

  *Answer:* Merge, writing 12 and 30 once, and stop at 4 values: the union sketch is *[5, 12, 19, 30]*. The values in both sketches are *[12, 30]*
  - Shared fraction: 12 and 30 are shared, out of 4, so $J approx 2 / 4 = 0.5$
  - Union size: $4 / 0.30 - 1 approx 12.3$. Intersection as a $k = 2$ sketch: $2 / 0.30 - 1 approx 5.67$, so $J approx 5.67 / 12.3 approx 0.46$
  - Through the union: $abs(A) approx 4 / 0.41 - 1 approx 8.76$ and $abs(B) approx 4 / 0.55 - 1 approx 6.27$, so $abs(A inter B) approx 8.76 + 6.27 - 12.33 approx 2.70$ and $J approx 2.70 / 12.33 approx 0.22$
  The spread is large because $k = 4$ is tiny. The through-the-union estimate is the shakiest, since it subtracts three noisy estimates

+ *What the sketches can tell you.* Using only the two sketches from problem 8 (and treating a hash value as identifying its item), decide whether each is true, false, or unknown: (a) the item with hash 19 is in $A$, (b) the item with hash 41 is in $B$, (c) the item with hash 60 is in $A$

  *Answer:*
  + *False.* $A$'s sketch holds every value of $A$ up to 41. 19 is below 41 and not in the sketch, so it isn't in $A$
  + *False.* $B$'s sketch holds every value of $B$ up to 55, and 41 isn't there
  + *Unknown.* 60 is bigger than everything in $A$'s sketch, so it could be in $A$ past the end of the sketch

+ *Skewed sizes.* Small set $S$ (100 items) is almost entirely inside large set $L$ (10,000 items). Explain why the MinHash shared-fraction estimate with $k = 100$ is often 0, and name the trick that helps a little

  *Answer:* The true $J$ is tiny (about 0.009), and $L$'s 100 smallest hashes come from its 10,000 items, so they are mostly items $S$ doesn't have. The shared items usually sit past the end of $L$'s sketch, the union sketch fills up with $L$'s values, and the overlap is never seen. The module's experiment got exactly 0 in 118 of 300 trials. *$k$-partitions* (keep the smallest few in each range of the top hash bits) spread samples over the whole range and help a little, but the safest fix is to compare sets of similar size

+ *Cumulative runtimes.* Give the Big-O for a connected graph with $n$ vertices and $m$ edges, unless noted
  + DFS with an adjacency list
  + Kruskal's with a heap and disjoint sets
  + Dijkstra's with an unsorted array on a dense graph
  + Floyd-Warshall
  + `buildHeap` on $n$ values
  + $m$ `find`s and `union`s with smart union and path compression

  *Answer:*
  + $O(n + m)$
  + $O(m log m) = O(m log n)$, since $m < n^2$ means $log m < 2 log n$
  + $O(n^2)$
  + $O(n^3)$, no matter how sparse or dense the graph is
  + $O(n)$, not $O(n log n)$, since most nodes are near the bottom and heapify down only a short way
  + $O(m dot alpha(m, n))$, so amortized $O(alpha(m, n))$ each

+ *Tree recursion.* Using the `BinaryTree<T>::TreeNode` struct (`data`, `left`, `right`), write `countLeaves(TreeNode* curr)`, which returns the number of leaves in the subtree rooted at `curr`. What is its runtime?

  *Answer:*
  ```cpp
  template <class T>
  int BinaryTree<T>::countLeaves(TreeNode* curr) const {
      if(curr == nullptr) {
          return 0;   // the empty tree has no leaves
      }
      if(curr->left == nullptr && curr->right == nullptr) {
          return 1;   // a leaf has no children
      }
      return countLeaves(curr->left) + countLeaves(curr->right);
  }
  ```
  Every node is visited once, so it's $O(n)$
