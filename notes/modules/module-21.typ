#import "../diagrams.typ": array-cells, sets, tree

= Disjoint Sets

We're starting to see data structures that ask weird questions. A priority queue is still a queue in the sense that you put things in and get things out, just in a strange order. A *disjoint set* is really different from anything we've seen before

A disjoint set stores a *partition* of a set. Recall that a partition splits a set into subsets so that every element appears in *exactly one* subset. @ds-partition shows a partition of the numbers 0 through 9 into four subsets

#figure(
  sets((2, 0, 1), (4, 3, 8), (7, 9), (6, 5)),
  caption: [Example: a partition of 0 through 9 into four subsets. The shaded element of each subset is its representative],
) <ds-partition>

== Representatives

How do we refer to one of these subsets? In a drawing, we could say "the yellow one", but that's only because we colored it. As the partition changes, subsets come and go, so we need a better way to name them

We identify each subset by its *canonical element*, also called its *representative*. "Canonical" is a weird word (it actually comes from religious law), but it just means the *official* element: the one we all agree represents the set. Which element we pick doesn't matter, as long as everyone agrees on it. In @ds-partition, we picked 2, 4, 7, and 6

This makes membership easy to check. If 3 says "I belong to the set represented by 4", and 8 also says "I belong to the set represented by 4", then 3 and 8 are in the same set

== The Disjoint Sets ADT

- `find(k)` - Returns the representative of the subset that contains `k`
- `union(k1, k2)` - Merges the subsets containing `k1` and `k2` into one subset
- `addElements(num)` - Adds `num` new elements, each in a brand new subset all by itself

In @ds-partition, `find(4)` returns 4 and `find(8)` also returns 4. So `find(4) == find(8)` tells us that 4 and 8 are in the same subset, which is the basic question this data structure answers

Calling `union(5, 7)` merges $\{6, 5\}$ and $\{7, 9\}$ into $\{5, 6, 7, 9\}$. The new subset needs a representative, which could be any of its elements, so after a `union`, the representative of at least one of the old subsets has to change

Why is this useful? We're keeping track of groupings, and we want to know whether two elements are in the same group. Mathematically, that's the same as asking whether two elements are related by an *equivalence relation*

We always label the elements $0$ through $n - 1$. If we want to store something other than integers, we keep a separate table on the side (like a dictionary) that maps each item to its number. Since we can never remove anything, that table never goes out of date

== A First Implementation

The most obvious implementation is an array where index `k` stores the representative of `k`. At the start, every element is in its own subset, so every index stores itself. @ds-array shows the array after a few unions, with three subsets represented by 1, 2, and 5

#figure(
  array-cells(1, 1, 2, 5, 1, 5, 5, 2),
  caption: [Example: the subsets $\{0, 1, 4\}$, $\{2, 7\}$, and $\{3, 5, 6\}$ stored in an array. Each index stores the representative of its subset],
) <ds-array>

`find` is as good as it gets: we just return `data_[k]`, which is $O(1)$

For `union`, we'll assume we're always called with two *representatives*. We can always guarantee that by calling `union(find(k1), find(k2))`, which only adds a constant amount of work, but keeping `find` and `union` separate will matter once we start analyzing this data structure. To merge the two subsets, we go through the whole array and change every element that belongs to `k1` so it belongs to `k2` instead

```cpp
// DisjointSets.cpp

/** Merges set `k1` into set `k2` by relabeling every element of `k1`
 * Runtime: O(n)
 */
void DisjointSets::_union(int k1, int k2) {
    // every element whose representative is `k1` now belongs to `k2`
    for(size_t i = 0; i < data_.size(); i++) {
        if(data_[i] == k1) { data_[i] = k2; }
    }
}
```

That's clearly correct, but it's $O(n)$! We're back to the same problem we started with for heaps: one operation is $O(1)$ and the other is $O(n)$. Will we end up at $O(log n)$ and $O(log n)$ like heaps did? As it turns out, no: we're going to end up with something far better

$O(n)$ is almost always terrible for a data structure, since you can do almost anything in $O(n)$. At this point, we're really just writing down which set every element belongs to, which hardly seems like a data structure. But it *is* correct, and it implements the whole ADT. Anything we build has to be right before it's fast, since otherwise the fastest algorithm is just `return 0;`. It's constant time, and the compiler might even remove it entirely, but it's completely useless

As for why we'd want this at all: it answers "are 3 and 5 in the same set?" with `find(3) == find(5)`. There are a number of algorithms that fundamentally depend on that question, and we'll see a really cool one soon, but they only work because a good disjoint set is a lot better than $O(n)$

== UpTrees

Our new data structure is a *forest of trees*, one tree per subset. The twist is that the trees point *upwards*: every node points to its *parent*, and the *root* of each tree is the representative of the subset. To `find` an element's representative, we just follow parent pointers up until we reach the root

We don't want actual pointers, though. Just like with heaps, we can avoid them, since every element is already named by an index $0$ to $n - 1$. Instead of storing each element's representative, we store its *parent's index*. A root has no parent, so it stores $-1$, which is never a valid index. When we add elements, every new element starts as its own root, so we initialize it to $-1$ (setting a big block of memory to the same value is also very fast for hardware)

@ds-uptrees stores the same three subsets from @ds-array as uptrees: 0 points to 1 and 1 points to 4, 7 points to 2, and 3 and 6 both point to 5

#figure(
  grid(
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
  ),
  caption: [Example: the subsets $\{0, 1, 4\}$, $\{2, 7\}$, and $\{3, 5, 6\}$ as uptrees. Every node points up to its parent, and the roots (highlighted) store $-1$],
) <ds-uptrees>

Which tree we build for a subset (like whether 0 points to 1 or straight to 4) depends on the order of the unions. We're not claiming this is the best set of trees for this data, just that this memory represents these trees. Also notice nothing here requires a *binary* tree: a node can have as many children as point to it

=== Find

To find the representative of `k`

+ If `data_[k]` is $-1$, then `k` is a root, so `k` is the representative
+ Otherwise, `data_[k]` is `k`'s parent, which is in the same set, so ask it for the representative instead

```cpp
// DisjointSets.cpp

/** Returns the representative (root) of the set containing `k`
 * Runtime: O(h), up to O(n) without smart union
 */
int DisjointSets::find(int k) {
    // a root stores -1, so `k` is its own representative
    if(data_[k] == -1) { return k; }

    // otherwise ask the parent, which is in the same set
    return find(data_[k]);
}
```

In @ds-uptrees, `find(7)` looks at 7, which stores 2. 2 stores $-1$, so the representative of 7 is 2. The running time of `find` is the *height of the uptree*, since we might have to walk all the way up from the bottom

=== Union

Since we always union two roots, all we have to do is make one root point to the other

```cpp
// DisjointSets.cpp

/** Hangs the uptree rooted at `r1` underneath the root `r2`
 * Runtime: O(1)
 */
void DisjointSets::_union(int r1, int r2) {
    data_[r1] = r2;
}
```

That's $O(1)$! Calling `union(4, 5)` on @ds-uptrees just stores 5 at index 4, which hangs the whole tree rooted at 4 underneath 5, like in @ds-union. Now `find(0)` goes from 0 to 1, to 4, to 5, which stores $-1$, so the representative of 0 is 5

#figure(
  grid(
    columns: 1,
    row-gutter: 1em,
    align: center,
    grid(
      columns: 2,
      column-gutter: 3em,
      align: top,
      tree((5, 3, 6, (4, (1, 0)))),
      tree((2, 7)),
    ),
    array-cells(1, 4, -1, 5, 5, -1, 5, 2, highlight: (4,)),
  ),
  caption: [After `union(4, 5)` on @ds-uptrees, the only change in memory is index 4, which now stores its new parent, 5],
) <ds-union>

=== How Bad Can It Get?

`union` is $O(1)$ and `find` is the height of the tree, so everything depends on how tall the trees get, and that depends on how people call `union`. If we start with every element by itself and call `union(0, 1)`, then `union(1, 2)`, then `union(2, 3)`, and so on, we get a single long line like @ds-chain, and `find(0)` is $O(n)$. This is the usual problem with trees: if we just depend on how people use them, they can end up terrible

#figure(
  tree((4, (3, (2, (1, 0))))),
  caption: [The worst case: `union(0, 1)`, `union(1, 2)`, `union(2, 3)`, `union(3, 4)` builds a single long line],
) <ds-chain>

=== The Ideal UpTree

The best possible uptree has every node pointing *directly* at the root, so `find` is $O(1)$. But even if we had two of those, unioning them makes one of them hang one level lower, like in @ds-ideal. To make it ideal again, we'd have to update every node of that tree to point at the new root. In an uptree, a node only knows its parent, not its children, so the only way to find every node in a tree is to check every element, which is exactly our first $O(n)$ implementation. That implementation was really just uptrees that were forced to always be ideal

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    align: horizon,
    grid(columns: 2, column-gutter: 3.5em, tree((7, 1, 2, 3)), tree((8, 4, 5, 6))),
    $->$,
    tree((8, 4, 5, 6, (7, 1, 2, 3))),
  ),
  caption: [Two ideal uptrees, where every node points straight at its root. After a `union`, the nodes of one tree are two steps from the new root instead of one],
) <ds-ideal>

So we can't keep our trees perfect, but we *can* choose how we union to keep them short and bushy instead of tall. If we unioned 1 into 0, then 2 into 0, then 3 into 0, and so on, we'd get a perfect tree instead of the line in @ds-chain

== Smart Union

When we union two trees, which one should point at the other? Consider the two sets in @ds-smart-before

#figure(
  grid(
    columns: 2,
    column-gutter: 4em,
    row-gutter: 1em,
    align: top,
    tree((4, (0, (8, 1)))),
    tree((7, (2, 3, 6), (5, 9, 10), 11)),
    [4 nodes, height 3], [8 nodes, height 2],
  ),
  caption: [Example: a tall set with only 4 nodes, and a short, bushy set with 8 nodes],
) <ds-smart-before>

There are two reasonable rules

- *Union by size* - Point the root of the set with *fewer nodes* at the root of the set with more nodes
- *Union by height* - Point the root of the *shorter* tree at the root of the taller tree

Both make the obvious choice in cases like unioning a single node into a big tree, but they disagree in @ds-smart-before. Union by size points 4 at 7, and union by height points 7 at 4. You can see both results in @ds-smart-after

#figure(
  grid(
    columns: 1,
    row-gutter: 0.8em,
    align: center,
    tree((7, (2, 3, 6), (5, 9, 10), 11, (4, (0, (8, 1)))), highlight: (4, 0, 8, 1)),
    [Union by size: 4 nodes get one step deeper, but the height grows to 4],
    tree((4, (0, (8, 1)), (7, (2, 3, 6), (5, 9, 10), 11)), highlight: (7, 2, 5, 11, 3, 6, 9, 10)),
    [Union by height: the height stays 3, but 8 nodes get one step deeper],
  ),
  caption: [Unioning the sets from @ds-smart-before. The highlighted nodes are the ones that got farther from the root],
) <ds-smart-after>

Union by size makes the fewest nodes worse: only 4 `find`s get slower, and 8 don't change at all, so on average our `find`s are faster. But union by height never makes the *worst case* worse unless it has to: in @ds-smart-after, union by size creates a node 4 steps from the root, while union by height keeps the height at 3. So which is better? We'll need to prove something about the heights of these trees to find out

=== Storing the Size

How do we know the size of each set without counting all of its nodes? Roots store $-1$, but we can store *any* negative number at a root and still tell that it's a root. So instead of $-1$, a root stores *$-$size*. No set has size 0, so this always works

In @ds-smart-before, index 4 stores $-4$ and index 7 stores $-8$. To union by size, we compare the two (the *more negative* one is the bigger set), point the smaller root at the bigger one, and store the sum of the two sizes in the new root, which is all $O(1)$. Pointing 4 at 7 stores 7 at index 4 and $-12$ at index 7

```cpp
// DisjointSets.cpp

/** Points the root of the smaller set at the root of the bigger one
 * Runtime: O(1)
 */
void DisjointSets::unionBySize(int r1, int r2) {
    // sizes are stored negated, so this is the merged set's size, negated
    int newSize = data_[r1] + data_[r2];
    // the more negative root is the bigger set
    if(data_[r1] < data_[r2]) {
        data_[r2] = r1;
        data_[r1] = newSize;
    } else {
        data_[r1] = r2;
        data_[r2] = newSize;
    }
}
```

Since a root can now store any negative number, `find` checks for `data_[k] < 0` instead of `data_[k] == -1`

=== Storing the Height

We could try the same trick with heights: store $-$height at the root. In @ds-smart-before, index 4 would store $-3$ and 7 would store $-2$. But there's a problem: a brand new element has height 0, and $-0$ is just 0, which looks like "my parent is index 0"

The fix is a little clunky but straightforward. We only care about the heights *relative to each other*, so store *$-$(height $+ 1$)* instead. Index 4 stores $-4$ and index 7 stores $-3$, and a new element stores $-1$ just like before

When does the height change? When we hang the shorter tree under the taller tree's root, the shorter tree's nodes all get one step deeper, so the new height is the bigger of the taller height and the shorter height $+ 1$. If the heights are different, the shorter height $+ 1$ is at most the taller height, so nothing changes. The height only grows when the two trees are the *same* height, and then it grows by exactly 1. If they're equal, it doesn't matter which root we pick, as long as we subtract 1 from the new root

```cpp
// DisjointSets.cpp

/** Points the root of the shorter uptree at the root of the taller one
 * Runtime: O(1)
 */
void DisjointSets::unionByHeight(int r1, int r2) {
    // the more negative root is the taller tree
    if(data_[r1] < data_[r2]) {
        data_[r2] = r1;
    } else if(data_[r1] > data_[r2]) {
        data_[r1] = r2;
    } else {
        // same height: the new tree is one taller
        data_[r1] = r2;
        data_[r2]--;
    }
}
```

Both of these are smart: union by height only makes a tree taller when the heights are equal, and union by size changes the running time of the fewest nodes. But how good are they really?

== Analysis of Smart Union

We want to show that with either rule, an uptree with $n$ nodes has height $O(log n)$. Just like with AVL trees, we prove the inverse: a tree of height $h$ must have *at least $2^h$ nodes*, so $n >= 2^h$, which means $h <= log n$

=== Union by Size

Union by size doesn't obviously attack the worst case, so it's the trickier one to prove. Instead of inducting on the height, we induct on the number of *links*: the number of times `union` has been called on the nodes in the tree. `union` is the only way a tree changes shape. Linking a tree built with 3 links to a tree built with 2 links makes a tree with $3 + 2 + 1 = 6$ links, so both pieces always have fewer links than the result

*Claim:* Every uptree built with union by size has $n >= 2^h$ nodes

*Base case:* A tree with 0 links has never had `union` called on it, so it's a single node with height 0, and $1 >= 2^0$

*Inductive hypothesis:* Every tree built with fewer than $i$ links has $n >= 2^h$

*Inductive step:* Any tree $R'$ with $i$ links was made by linking two trees with fewer links: $S$ was hung below the root of $R$. Since we union by size, $R$ has *at least as many nodes as* $S$

- *Case 1:* $h(R) > h(S)$. Hanging the shorter $S$ below $R$'s root doesn't make the tree taller, so $h(R') = h(R)$. But we added nodes, so $n(R') > n(R) >= 2^(h(R)) = 2^(h(R'))$
- *Case 2:* $h(R) <= h(S)$. Now the tallest path goes through $S$, so $h(R') = h(S) + 1$. $R$ has at least as many nodes as $S$, so

$ n(R') = n(R) + n(S) >= 2 dot n(S) >= 2 dot 2^(h(S)) = 2^(h(S) + 1) = 2^(h(R')) $

Either way, $n(R') >= 2^(h(R'))$. Taking the log of both sides gives $h <= log n$, so the height is $O(log n)$

Intuitively, for a tree to get tall, it needs a lot of unions, which bring in a lot of nodes, and since the bigger tree always goes on top, it was probably already the taller one anyways

=== Union by Height

This proof is more direct, since we can induct on the height itself

*Claim:* Every uptree built with union by height has $n >= 2^h$ nodes

*Base case:* A tree of height 0 has 1 node, and $1 >= 2^0$

*Inductive hypothesis:* Every tree of height less than $k$ has $n >= 2^h$

*Inductive step:* With union by height, the only way to get a tree of height $k$ is to link two trees that both have height $k - 1$ (if one were shorter, it wouldn't make the result taller). By the inductive hypothesis, each has at least $2^(k - 1)$ nodes, so together

$ n >= 2^(k - 1) + 2^(k - 1) = 2 dot 2^(k - 1) = 2^k $

So again, $h <= log n$

Either rule gives us `find` in $O(log n)$ and `union` in $O(1)$, which is already one of the best runtimes we've seen for a data structure. But we can do better

== Path Compression

Suppose we call `find(6)` on the uptree on the left of @ds-path-compression (a tree this tall couldn't actually come from smart union without a lot more nodes, but the idea is the same). `find(6)` calls `find(4)`, which calls `find(2)`, then `find(7)`, `find(9)`, and finally `find(10)`, which is the root. Then 10 gets passed all the way back down

That's correct, but on the way back down, every one of those calls *knows* the root is 10. So before 6 returns, it might as well update itself to point straight at 10, and so might 4, 2, and 7 (9 already points at 10, but updating it doesn't hurt). This technique is called *path compression*, since it compresses the long path into a short, bushy tree, which you can see on the right of @ds-path-compression

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    align: horizon,
    tree((10, (9, (7, (2, (4, 6))))), highlight: (6, 4, 2, 7, 9)),
    $->$,
    tree((10, 9, 7, 2, 4, 6), highlight: (6, 4, 2, 7, 9)),
  ),
  caption: [Example: calling `find(6)` with path compression. Every node on the path from 6 to the root ends up pointing directly at the root, 10],
) <ds-path-compression>

The code only adds a tiny constant amount of work, since we're already returning through every call on the path. Instead of just returning the result, each call stores it first

```cpp
// DisjointSets.cpp

/** Returns the root of `k` and points every node on the path at it
 * Runtime: amortized O(α(m, n))
 */
int DisjointSets::find(int k) {
    // roots store a negative number (the size or height), so `k` is the root
    if(data_[k] < 0) { return k; }
    // point k straight at the root before returning it
    data_[k] = find(data_[k]);
    return data_[k];
}
```

This doesn't eventually give us a perfect tree: if we keep calling `find(4)`, nothing outside of 4's path ever improves. But every node we `find`, and every node on its path, gets better. It's a bit like a cache: something we never look at never improves, but we never look at it, so who cares?

=== Union by Rank

Path compression changes the heights of trees, and there is no cheap way to keep track of a tree's height after compressing paths in it. So union by height doesn't work anymore. Instead, we use *union by rank*

- Every new uptree starts with a *rank* of 0
- When we union two roots, the root with the *larger rank* becomes the new root
- If the two ranks are *equal*, pick either one as the new root and increase its rank by 1

Without path compression, this is exactly union by height, so rank and height are the same thing. But rank is tied to the *history* of the unions, not the current shape of the tree, so path compression doesn't change it: making a tree shorter never reduces its rank. We store it the same way as the height, as $-("rank" + 1)$ at the root, so the code is the same as `unionByHeight`

Some things are always true about ranks

- The rank of every node is *less* than the rank of its parent, since the root with the larger rank always ends up on top
- Ranks only change at roots, and once a node stops being a root, it never becomes one again. Path compression only moves nodes *up* the tree, and everything below them moves up too, so everything above a node still has a larger rank

The same proof as union by height (with "rank" instead of "height") shows that a tree of rank $r$ has at least $2^r$ nodes, even with path compression

== Iterated Log

To describe how good this is, we need a new function. $log n$ counts how many times we have to *divide* $n$ by 2 to get down to 1. The *iterated log*, $log^* n$ (read "log star"), counts how many times we have to take the *log* to get down to 1

$ log^* n = cases(0 & "if" n <= 1, 1 + log^*(log n) & "otherwise") $

#table(
  columns: 2,
  table.header([$n$], [$log^* n$]),
  [1], [0],
  [2], [1],
  [4], [2],
  [16], [3],
  [65,536], [4],
  [$2^(65536)$], [5],
)

$2^(65536)$ is way more than the number of atoms in the universe, and $log^*$ is only 5. It's a really slow-growing function

=== Analysis Sketch

With smart union and path compression, any sequence of $m$ `union` and `find` operations on $n$ elements takes $O(m log^* n)$ time total, or amortized $O(log^* n)$ per operation. The full proof takes more than a whole lecture, so here is just the rough idea

- Once a node stops being a root, its rank never changes again
- Group the non-root nodes into *buckets* by rank, where each bucket covers a range of ranks (like $[1]$, $[2]$, $[3, 4]$, $[5, 16]$, $[17, 65536]$, ...). There are only $log^* n$ buckets, and since a tree of rank $r$ has at least $2^r$ nodes, high-rank buckets can't hold many nodes
- Charge the work of every `find` step by step: steps of distance 0 or 1 get charged to the `union` that created the root, and every other step moves a node up to a parent of higher rank, which gets charged to the node moving through the buckets. Since there are only $log^* n$ buckets, the total charge works out to $O(m log^* n)$

The interesting idea here is *charging* work to different places, similar to how we charged copies to inserts in amortized analysis

=== The Real Bound

$O(m log^* n)$ is great, but the best bound that has been proven is even better: $m$ operations take $O(m dot alpha(m, n))$ time, where $alpha$ is the *inverse Ackermann function*

The Ackermann function grows absurdly fast. For example, $A(4, 2) = 2^(65536) - 3$, which is 19,729 digits long. So its inverse grows even slower than $log^*$: where $log^*$ reaches 5, $alpha$ is only around 3. Technically $alpha$ isn't constant, since it does go to infinity as $n$ goes to infinity, just very, very slowly: for any input that could fit in the universe, it's at most about 4

So a disjoint set implemented with smart union and path compression runs a sequence of $m$ `union` and `find` operations in worst case $O(m dot alpha(m, n))$ time. Dividing by $m$, that's an amortized $O(alpha(m, n))$ per operation, which is *effectively constant*. Any single operation might take longer (like a `find` after a long chain of unions), but averaged over all of them, it's practically $O(1)$

#table(
  columns: 3,
  table.header([*Implementation*], [*`find`*], [*`union`*]),
  [Array of representatives], [$O(1)$], [$O(n)$],
  [UpTrees], [$O(n)$], [$O(1)$],
  [UpTrees + smart union], [$O(log n)$], [$O(1)$],
  [UpTrees + smart union + path compression], [amortized $O(alpha(m, n))$, effectively $O(1)$], [amortized $O(alpha(m, n))$, effectively $O(1)$],
)

Disjoint sets turn out to be a very useful tool for a number of algorithms on *graphs*, which are coming up next
