#import "../diagrams.typ": array-cells, tree

= Heaps

Recall the priority queue ADT: `insert`, `removeMin`, and `isEmpty`. Our implementation is a *min-heap*: a complete binary tree, stored in an array, where every node is at least as small as both of its children. Since the tree is always complete, we always know its shape after an `insert` (a new rightmost node on the bottom level) or a `removeMin` (the last node disappears), and we fix the heap property with *heapify up* or *heapify down*, each in $O(log n)$ time

A priority queue doesn't have to put the smallest value first. A *max-heap* keeps the largest value at the root, with every node at least as *large* as its children. In fact, we can build a heap around any comparison we want, and whatever comes first under that comparison comes out first

So far, a heap isn't much better than a balanced BST, which can also `insert` in $O(log n)$ and find the minimum as its leftmost node. We'd still pick the heap, since storing it in an array is much more compact, but the real advantage is *building* one

== Building a Heap

Given an array of $n$ values, how do we turn it into a heap? The algorithm we'll call `buildHeap` is specifically the *best* way we know to do this, so if you're asked to write `buildHeap`, it needs to be as good as the one we find here. Let's look at three options

=== Option 1: Sort the Array

If we sort the array (ignoring index 0, where we keep the size) from smallest to largest, it's already a heap! The array stores the tree one level at a time, so after sorting, every value on a higher level is no larger than every value on a lower level, so every node is no larger than its children

But the best possible *comparison sort* (a sort that only compares two values at a time, which is all we know how to do with our values) has been proven to take $O(n log n)$ time. That's no better than inserting $n$ values into a balanced BST

=== Option 2: Insert $n$ Times

We could just `insert` each value into an empty heap, one at a time. Each `insert` puts the value at the end and *heapifies up*, so this is the same as calling heapify up on index 2, then 3, then 4, all the way to $n$. Each heapify up takes $O(log n)$, so our first guess is $O(n log n)$

=== Option 3: Heapify Down From the Bottom Up

This one is more subtle. When we call heapify down on a node, the node itself might be in the wrong place, but its two subtrees are already correct heaps. So we can think of heapify down as *merging two heaps with a new value on top*: if we have two correct heaps (no matter what's in them), stick a new value on top of them, and heapify down, we get one correct heap

So we build the heap from the bottom up

+ Every leaf is already a correct heap on its own, so we skip all of them. The last node with a child is the parent of the last node, at index $floor(n / 2)$
+ Call heapify down on index $floor(n / 2)$, then $floor(n / 2) - 1$, and so on, all the way back to the root at index 1
+ By the time we heapify down any node, both of its subtrees have already been turned into heaps, so each call merges two heaps into a bigger one, and after the root, the whole array is a heap

In @heap-build-start, the array has 10 values, so the leaves are at indices 6 through 10, and the first node we heapify down is at index $floor(10 / 2) = 5$

#figure(
  tree((12, (15, (9, 1, 7), (3, 10, none)), (6, 14, 8)), highlight: (14, 8, 1, 7, 10)),
  caption: [Example: the array 12, 15, 6, 9, 3, 14, 8, 1, 7, 10 viewed as a complete tree. The highlighted leaves are already heaps, so `buildHeap` starts at index 5 (holding 3)],
) <heap-build-start>

@heap-build-steps then heapifies down each node from index 5 back to the root. Some nodes, like 3 and 6, are already smaller than their children, so they don't move at all. Others, like 15 and 12, sink down more than one level

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Start], array-cells(none, 12, 15, 6, 9, 3, 14, 8, 1, 7, 10),
    [Index 5 (3): no swap], array-cells(none, 12, 15, 6, 9, 3, 14, 8, 1, 7, 10, highlight: (5,)),
    [Index 4 (9): swap with 1], array-cells(none, 12, 15, 6, 1, 3, 14, 8, 9, 7, 10, highlight: (4, 8)),
    [Index 3 (6): no swap], array-cells(none, 12, 15, 6, 1, 3, 14, 8, 9, 7, 10, highlight: (3,)),
    [Index 2 (15): sinks past 1, 7], array-cells(none, 12, 1, 6, 7, 3, 14, 8, 9, 15, 10, highlight: (2, 4, 9)),
    [Index 1 (12): sinks past 1, 3, 10], array-cells(none, 1, 3, 6, 7, 10, 14, 8, 9, 15, 12, highlight: (1, 2, 5, 10)),
    [Done], tree((1, (3, (7, 9, 15), (10, 12, none)), (6, 14, 8))),
  ),
  caption: [`buildHeap` on the array from @heap-build-start, heapifying down from index 5 back to the root. The highlighted cells are the ones that changed],
) <heap-build-steps>

Each heapify down can take up to the height of the tree, and we do $n / 2$ of them, so our first guess is $O(n log n)$ again. It turns out that guess is wrong

```cpp
// Heap.hpp

/** Turns the unsorted array into a heap by heapifying down from the bottom up
 * Runtime: O(n)
 */
template <class T>
void Heap<T>::buildHeap() {
    // every leaf is already a heap, so start at the parent of the last node
    for(size_t i = _parent(size_); i > 0; i--) {
        _heapifyDown(i);
    }
}
```

== Analysis

All three options looked like $O(n log n)$ at first. Sorting really is: no comparison sort can do better. To compare the other two, we count the number of swaps, assuming the worst case is a *perfect* tree of height $h$, so $n = 2^(h + 1) - 1$ (a perfect tree has more nodes on every level, so it can only take more work)

=== Inserting $n$ Times

When we heapify up a node, it can travel up as far as its *depth*, its distance from the root. There are $2^d$ nodes at depth $d$, so

$ "swaps" = sum_(d = 0)^h d dot 2^d = 0 dot 1 + 1 dot 2 + 2 dot 4 + 3 dot 8 + ... + h dot 2^h $

The problem is that the *most* nodes (the bottom level, about half of them) do the *most* work (the full height). The last level alone is $h dot 2^h approx (n / 2) log n$, so this really is $O(n log n)$

=== Heapify Down From the Bottom Up

When we heapify down a node, it can travel down as far as its *height*, its distance to the bottom. The leaves have height 0 and do no work at all, the level above them can do 1 swap each, and only the root can travel the whole height of the tree. @heap-swap-counts labels every node of a perfect tree with how many swaps each approach could need

#figure(
  grid(
    columns: 1,
    row-gutter: 1em,
    align: center,
    tree((0, (1, (2, 3, 3), (2, 3, 3)), (1, (2, 3, 3), (2, 3, 3)))),
    [Insert $n$ times: each node can move up its depth],
    tree((3, (2, (1, 0, 0), (1, 0, 0)), (2, (1, 0, 0), (1, 0, 0)))),
    [Heapify down from the bottom up: each node can move down its height],
  ),
  caption: [The most swaps each node can need in a perfect tree of height 3. Inserting puts the biggest numbers on the biggest level, while bottom-up heapify down puts them on the smallest],
) <heap-swap-counts>

There are $2^(h - k)$ nodes at height $k$, so the total number of swaps is the sum of the heights of every subtree

$ "swaps" = sum_(k = 0)^h k dot 2^(h - k) = 2^h sum_(k = 0)^h k / 2^k $

The sum $sum_(k = 0)^infinity k / 2^k$ converges to exactly 2, so

$ "swaps" < 2^h dot 2 = 2^(h + 1) = n + 1 $

The exact total for a perfect tree is $2^(h + 1) - h - 2 = n - h - 1$ swaps, which is less than $n$. So `buildHeap` runs in *$O(n)$* time!

The intuition: when there are only a few subtrees (near the root), each one does a lot of work, but when there are lots of subtrees (near the bottom), each one does very little. With heapify up, it's the other way around, so the work grows with the number of nodes. This should feel like nonsense at first, since all three options look like $O(n log n)$, and that's the right intuition to start with. It only comes out to $O(n)$ when you work through the math

#table(
  columns: 2,
  table.header([*Way to build a heap*], [*Running time*]),
  [Sort the array], [$O(n log n)$],
  [Insert $n$ times (heapify up)], [$O(n log n)$],
  [Heapify down from the bottom up (`buildHeap`)], [$O(n)$],
)

That's the real advantage of a heap over a BST: building a BST out of $n$ values takes $O(n log n)$, but we can turn any array into a heap in $O(n)$
