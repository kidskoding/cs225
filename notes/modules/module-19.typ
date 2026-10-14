#import "../diagrams.typ": array-cells, steps, tree

#let heap = (4, (5, (15, 16, 25), (9, 14, 12)), (6, (7, 11, none), 20))

= Priority Queues

We finally get a new abstract data type! Besides creating an empty one, it only has three operations

- `insert` - Adds a value (takes a `const T&`)
- `remove` - Takes no arguments, and removes and returns a value
- `isEmpty` - Checks whether there is anything left to remove

So far, that sounds like a queue or a stack. What makes this one special is *which* value `remove` returns

== What Can We Store?

Unlike most of the data structures we've seen, we can't store just any kind of data in this one. Strings and integers work fine, but a general node, or a pointer, does not

The reason is that everything we store must be *comparable*: given two values, we have to be able to tell which one is smaller. Strings and integers have a `<`, but there's no meaningful way to say whether one node is smaller than another

Pointers are the surprising one, especially if you come from ECE. A pointer is just a memory location, so it feels like we should be able to compare them, and in assembly we could. But formally, C++ doesn't give a meaningful result for comparing two unrelated pointers with `<` (the standard leaves it unspecified). You *can* work around it, by writing your own comparison or by comparing with `std::less`, but the type itself doesn't come with one

So the one requirement is that the type has a *priority operator* that orders its values, generally thought of as `<`. Technically any relationship that produces an ordering works (`>`, `<=`, ...), and we can choose whatever priority we want

== The Priority Queue ADT

Suppose we insert 12, 7, 225, and $-57$, in that order. If we then call `remove`, we don't get 12 (the first in, like a queue) or $-57$ (the last in, like a stack). We get the *smallest* value, $-57$. Calling `remove` again returns 7, and again returns 12

If we then insert 42 and 21, the next `remove` returns 21, then 42, and finally 225

This ADT is called a *priority queue*. It stores its elements in some way the user never sees, but `remove` always returns the element with the *smallest* value. Technically, this is a *min priority queue*, which is the standard when theoreticians talk about a priority queue (a max priority queue returns the largest instead)

```cpp
// PriorityQueue.h

template <typename T>
class PriorityQueue {
public:
    void insert(const T& value);
    T remove(); // removes and returns the smallest value
    bool isEmpty() const;
};
```

== Implementations So Far

With the data structures we already know, there are four ways we could implement a priority queue

- *Unsorted array* - `insert` just adds the value to the end in $O(1)$ time, but `remove` has to look through the whole array for the minimum and then shift everything back together, which is $O(n)$
- *Unsorted list* - `insert` is $O(1)$, but `remove` still has to look through the whole list for the minimum, which is $O(n)$
- *Sorted array* - If we sort it from largest to smallest, the minimum is always at the end, so `remove` is $O(1)$. But `insert` has to find the right place and shift everything over to make space for it, which is $O(n)$
- *Sorted list* - The same trade-off: `insert` is $O(n)$ and `remove` is $O(1)$

@pq-arrays compares the two array versions holding the values from our example

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: center + bottom,
    array-cells(12, 7, 225, -57, none, highlight: (3,)),
    array-cells(225, 12, 7, -57, none, marks: (min: 3)),
    [Unsorted: scan everything to find the min], [Sorted largest to smallest: the min is at the end],
  ),
  caption: [Two array-based priority queues holding 12, 7, 225, $-57$. The unsorted array makes `insert` cheap and `remove` expensive, and the sorted array does the opposite],
) <pq-arrays>

#table(
  columns: 3,
  table.header([*Implementation*], [*`insert`*], [*`remove`*]),
  [Unsorted array], [$O(1)$], [$O(n)$],
  [Unsorted list], [$O(1)$], [$O(n)$],
  [Sorted array], [$O(n)$], [$O(1)$],
  [Sorted list], [$O(n)$], [$O(1)$],
)

Every option makes one operation $O(1)$ and the other $O(n)$. Can we do better?

We actually already have a data structure that does: a *balanced BST*, like an AVL tree. `insert` takes $O(log n)$ time, and the minimum is just the leftmost node (keep going left until you can't anymore), which we can find and remove in the height of the tree, also $O(log n)$

But BSTs are fairly complicated, and there is a classic data structure built specifically for this that is a little bit better and shows some interesting ideas

== Heaps

@pq-heap shows our new data structure. It's a binary tree, but it is *not* a BST: 14 is smaller than 15, but it isn't to the left of 15

#figure(
  tree(heap),
  caption: [Example: a min-heap. Every node is smaller than both of its children, and the tree is complete],
) <pq-heap>

So what's true of every node? *The root of every subtree is the minimum of that subtree*, or in other words, every node is smaller than the roots of both of its subtrees. On top of that, it's a *complete* tree: every level is full except the last, which is filled from the left

A binary tree with these two properties is called a *heap*, which is an implementation of the priority queue ADT. Formally, a complete binary tree $T$ is a *min-heap* if

- $T = emptyset$, or
- $T = (r, T_L, T_R)$, where $r$ is less than the roots of $T_L$ and $T_R$, and $T_L$ and $T_R$ are min-heaps

The minimum is always at the root, so finding it is trivial

#quote(block: true)[The heap *data structure* has nothing to do with *heap memory*, where `new` allocates from. Computer science just reuses names in confusing ways]

== Storing a Heap in an Array

We'd always know where the minimum is even if the tree weren't complete, so why require it? Because in a complete tree, every level except the last has an *exact* number of nodes: 1, 2, 4, 8, ... And even the last level is easy, since if we know the total number of nodes, we can subtract all the other levels

Those powers of two should remind us of the doubling array. So instead of storing a tree with pointers (pointers are a pain), we store the tree in an *array*, one level at a time: the root, then the second level, then the third, and so on. The tree is how we *think* about the heap, and the array is how we actually *store* it, as you can see in @pq-heap-array

#figure(
  grid(
    columns: 1,
    row-gutter: 1.5em,
    align: center,
    tree(heap),
    array-cells(none, 4, 5, 6, 15, 9, 7, 20, 16, 25, 14, 12, 11),
  ),
  caption: [The heap from @pq-heap (conceptual storage) and the array that actually stores it, one level at a time (physical storage). Index 0 is left empty],
) <pq-heap-array>

We leave index 0 empty (or store the number of nodes there), so the root is always at index 1. That used to be the standard way to implement a heap, back when heaps mostly stored integers. Nowadays heaps usually store more complicated types, so people tend to store the size separately and start the root at index 0. Either works, but starting at 1 makes the math easy

With the root at index 1, for a node at index $i$

- *Left child* - $2i$
- *Right child* - $2i + 1$
- *Parent* - $floor(i / 2)$, which is just integer division in code
- *Last node* - If the heap has $n$ nodes, the last one is at index $n$

For example, in @pq-index-math, 5 is at index 2: its left child is at index 4 (15), its right child is at index 5 (9), and its parent is at index 1 (4). 20 is at index 7, so its parent is at index $floor(7 / 2) = 3$, which is 6

#figure(
  array-cells(none, 4, 5, 6, 15, 9, 7, 20, 16, 25, 14, 12, 11, marks: ("parent(2)": 1, "i = 2": 2, "left(2)": 4, "right(2)": 5), highlight: (2,)),
  caption: [Index math for the node at index 2 (holding 5): its parent is at index 1, and its children are at indices 4 and 5],
) <pq-index-math>

#quote(block: true)[If the root is at index 0 instead, the formulas become $2i + 1$, $2i + 2$, and $floor((i - 1) / 2)$. Nothing is wrong with that, the math is just messier (you can't double 0 to find its left child)]

That's everything we need: no pointers, just an array and a size, and we can move up and down the tree. A pointer-based heap is possible, but it would need pointers going *up* to parents too, and the array uses a lot less memory

The only question left is how to keep it a heap. There is no rotating an array, and we can't leave holes in it, so the tree must always stay complete. Luckily, only two operations change the heap: `insert` and `removeMin`

== Insert

After inserting one more node, the tree has to stay complete, so we *already know where the new node goes*: the next open spot on the last level, which is index $n + 1$ in the array

+ Put the new value at index $n + 1$
+ If it's smaller than its parent, the heap property is broken, so *heapify up*: swap it with its parent, and repeat from the parent's index until it's no longer smaller than its parent, or it reaches the root

Inserting 21 into the heap from @pq-heap puts it under 7, and since 21 is larger than 7, the heap is still valid with no swaps at all

Inserting 3 next puts it under 20. 3 is smaller than 20, so we swap them. Then 3 is smaller than its new parent 6, so we swap again, and then it's smaller than 4, so we swap one last time and 3 becomes the new root. You can see each swap in @pq-heapify-up, in the array where it actually happens. Everything below 3 is fine after each swap, since 3 is smaller than whatever it swapped with, so we only ever have to keep checking *above*

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Insert 3 at index 14], array-cells(none, 4, 5, 6, 15, 9, 7, 20, 16, 25, 14, 12, 11, 21, 3, highlight: (14,)),
    [3 < 20 (index 7): swap], array-cells(none, 4, 5, 6, 15, 9, 7, 3, 16, 25, 14, 12, 11, 21, 20, highlight: (7,)),
    [3 < 6 (index 3): swap], array-cells(none, 4, 5, 3, 15, 9, 7, 6, 16, 25, 14, 12, 11, 21, 20, highlight: (3,)),
    [3 < 4 (index 1): swap], array-cells(none, 3, 5, 4, 15, 9, 7, 6, 16, 25, 14, 12, 11, 21, 20, highlight: (1,)),
    [Done], tree((3, (5, (15, 16, 25), (9, 14, 12)), (4, (7, 11, 21), (6, 20, none))), highlight: (3,)),
  ),
  caption: [Inserting 3 (after 21). It starts at the next open spot, index 14, and heapifies up through its parents at indices 7, 3, and 1 to become the new root],
) <pq-heapify-up>

Heapify up isn't constant time: it can go all the way up the tree, which is the height. But the tree is complete, and a complete tree is only a constant amount off of a perfect tree, so its height is $O(log n)$. So `insert` is $O(log n)$

If the array runs out of space, we double it, just like `push_back` on a vector, which gives amortized constant time growth. In a heap, doubling also happens to allocate *exactly* the space for the next level of the tree

```cpp
// Heap.hpp

/** Inserts `key` at the end of the array and heapifies it up
 * Runtime: O(log n)
 */
template <class T>
void Heap<T>::_insert(const T& key) {
    // check to ensure there's space to insert an element
    // ...if not, grow the array
    if(size_ == capacity_) { _growArray(); }

    // insert the new element at the end of the array
    item_[++size_] = key;

    // restore the heap property
    _heapifyUp(size_);
}
```

`++size_` moves the size from the old last position to the new last position, and we put the key there. Then we heapify up starting from the *index* `size_`, not from the key, since that's where we just put it

```cpp
// Heap.hpp

/** Swaps the value at `index` up until it is no smaller than its parent
 * Runtime: O(log n)
 */
template <class T>
void Heap<T>::_heapifyUp(size_t index) {
    // index 1 is the root, which has no parent to swap with
    if(index > 1) {
        // swap with the parent if it is smaller, then keep going up
        if(item_[index] < item_[_parent(index)]) {
            std::swap(item_[index], item_[_parent(index)]);
            _heapifyUp(_parent(index));
        }
    }
}
```

- `index > 1` is the base case: once we reach the root, there is nothing above us, so we're done
- Otherwise, we compare the *value* at `index` with the value at its parent's index, and if ours is smaller, swap the two values and recurse on the parent's index. The confusing part is switching between indexes and values, just like a pointer versus the thing it points to
- Duplicates are fine: if we're not *strictly* smaller, we don't swap. The heap property just becomes "less than or equal to", and the root is still a smallest value
- `std::swap` takes its two arguments by reference, so it swaps the values in the array in place

#quote(block: true)[`size_t` is an unsigned integer type that is guaranteed to be big enough to hold any array index. C++ only promises that an `int` is no smaller than a `short` and no bigger than a `long`, so the size of an `int` depends on your compiler and computer. When you need an exact size, there are types like `uint32_t` and `int64_t` (unsigned and signed, with that many bits)]

== Remove Min

Once again, structurally we already know which node goes away: the tree has to stay complete, so the node in the *last* position (index $n$) is the one that disappears, even though the value we're removing is at the root

This might feel familiar from removing a node with two children in a BST

+ Save the minimum value at the root
+ Move the last value into the root, and shrink the size by one. The tree now has the correct shape, but the root is probably not the smallest anymore
+ *Heapify down* from the root: compare the node with both of its children, and if it's larger than the *smaller* child, swap with that child. Repeat from the child's index until the node is smaller than both children, or it's a leaf
+ Return the saved minimum

Calling `removeMin` on the heap from @pq-heap removes 4 and moves 11, the last value, to the root. 11 is larger than its smaller child 5, so they swap. Then 11 is larger than its smaller child 9, so they swap again. Now 11 is smaller than both of its children, 14 and 12, so we stop. You can follow it in @pq-heapify-down

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    align: (right + horizon, left + horizon),
    [Remove 4, the last value is 11], array-cells(none, 4, 5, 6, 15, 9, 7, 20, 16, 25, 14, 12, 11, highlight: (1, 12)),
    [Move 11 to the root, shrink], array-cells(none, 11, 5, 6, 15, 9, 7, 20, 16, 25, 14, 12, highlight: (1,)),
    [Children 5, 6: swap with 5], array-cells(none, 5, 11, 6, 15, 9, 7, 20, 16, 25, 14, 12, highlight: (2,)),
    [Children 15, 9: swap with 9], array-cells(none, 5, 9, 6, 15, 11, 7, 20, 16, 25, 14, 12, highlight: (5,)),
    [11 < 14 and 12: done], tree((5, (9, (15, 16, 25), (11, 14, 12)), (6, 7, 20)), highlight: (11,)),
  ),
  caption: [`removeMin` on the heap from @pq-heap. The last value moves to the root and heapifies down, always swapping with the smaller child],
) <pq-heapify-down>

Swapping with the *smaller* child is what keeps this correct: whatever moves up was smaller than or equal to both children, so it's a valid root for that subtree. It's one swap per level, so `removeMin` is $O(log n)$ too

```cpp
// Heap.hpp

/** Removes and returns the smallest value (the root)
 * Runtime: O(log n)
 */
template <class T>
T Heap<T>::_removeMin() {
    // swap with the last value
    // the minimum is always the root at index 1
    T minValue = item_[1];
    item_[1] = item_[size_];
    size_--;

    // restore the heap property
    _heapifyDown(1);

    // return the minimum value
    return minValue;
}
```

```cpp
// Heap.hpp

/** Swaps the value at `index` down until it is no larger than its children
 * Runtime: O(log n)
 */
template <class T>
void Heap<T>::_heapifyDown(size_t index) {
    if(!_isLeaf(index)) {
        // swap with the smaller child so the heap property holds below
        size_t minChildIndex = _minChild(index);
        if(item_[index] > item_[minChildIndex]) {
            std::swap(item_[index], item_[minChildIndex]);
            _heapifyDown(minChildIndex);
        }
    }
}
```

- `_isLeaf(index)` checks whether `2 * index > size_`. If our left child's index would be past the end of the heap, we have no children. We don't need to check the right child, since the tree is complete, so a right child can't exist without a left child
- `_minChild(index)` returns the index of the smaller child (or the left child, if there is no right child)
- If our value is larger than our smaller child's, we swap down and heapify down again from the child's index

== Heap vs. BST

Both `insert` and `removeMin` are $O(log n)$, the same as a balanced BST. So a heap isn't obviously better yet, but it uses a lot less space because of the array, and in practice it runs faster

The real advantage shows up when turning an existing array into a heap. Building a BST from $n$ values takes $O(n log n)$ time, since we insert them one at a time, but we can turn an array into a heap in just $O(n)$ time. That, and using a heap to sort, come next
