#import "../diagrams.typ": btree, tree

= BTrees

== Why AVL Trees Fall Short

In Big-O, we assume that we have uniform time for all operations, but this is not always the case

AVL trees (and red-black trees) assume that following a pointer, or doing a rotation, takes a constant and *small* amount of time. That's true when the whole tree lives in memory, since memory is fast. We can wrap it in a Big-O and it correctly describes what's going on

But what if following a pointer was really, really slow? For example, what if the tree was stored on a hard disk, or spread across a bunch of computers instead of a single one, like a huge database? Finding something on a spinning disk takes a lot of time, and two nodes on a disk aren't necessarily anywhere near each other

#table(
  columns: 2,
  table.header([*Where the next node lives*], [*Rough cost to reach it*]),
  [Memory], [\~100 instructions],
  [SSD], [\~1,000 instructions],
  [Spinning disk seek, or another server], [\~40 ms, or \~40 million instructions],
)

Following one of these slow pointers is called a *seek*. The name comes from when B-trees were first designed for spinning hard drives: the read head had to physically move to the right spot on the disk, and that time was called the *seek time*

Technically, Big-O still says this is $O(1)$ per node, since 40 million is a constant. But instead of 6 or 7, our constant is now 40 million! $log n$ is really small, until every one of those $log n$ steps costs 40 milliseconds. The height of the tree starts to cost a lot

So we want the tree to be *really* short, but we still want the best part of a BST: when we search, we only go down, so we only ever look at the relevant parts of the tree

A binary tree divides the data we're looking at in half at every step. But you know what's better than dividing by 2? Dividing by 4, or 16, or 1024. Pointers are expensive, but nodes are okay, so we pack *more than one key* into each node and have fewer pointers. Compare the two trees in @btree-shorter, which hold the same seven keys

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: horizon + center,
    tree((25, (10, 5, 20), (40, 30, 50))),
    btree(("10 30", "5", "20 25", "40 50")),
    [Binary: height 2], [Multiple keys per node: height 1],
  ),
  caption: [The same seven keys in a perfect BST and in a tree with up to two keys per node. Packing more keys into each node makes the tree shorter, so a search follows fewer slow pointers],
) <btree-shorter>

== B-Trees

A *B-Tree* is a self-balancing search tree designed for efficient storage and retrieval on disks. Unlike a binary search tree that stores only one key per node, each B-Tree node can hold multiple keys and have multiple children

- The keys inside a node are kept in *sorted order*, and the children split the key ranges between them
- All leaves appear at the same depth, so the tree remains balanced
- Because each node can hold many keys (often filling a disk block), the tree height is very small, which reduces disk accesses
- Operations like search, insertion, and deletion still take *$O(log n)$* time, but with a much smaller constant factor, making B-Trees ideal for databases and file systems

A *B-tree of order $m$* is an *$m$-way* (or *$m$-ary*) tree, meaning every node has between 0 and $m$ children

- Every node stores *at most $m - 1$ keys*, one less than the maximum number of children
- The keys in a node are stored in a sorted array that is *preallocated* to hold all $m - 1$ keys, so there is no amortized resizing to worry about
- An internal node with $k$ keys has $k + 1$ children: one to the left of each key, plus one to the right of the last key

Take the small B-tree in @btree-order-3: its root holds two keys, 20 and 40, which split its three children by range.

#figure(
  btree(("20 40", "5 10", "25 30", "50 60")),
  caption: [Example: a B-tree of order 3. Each node holds at most 2 sorted keys, the keys 20 and 40 split the children into $< 20$, between 20 and 40, and $> 40$, and every leaf is at the same depth],
) <btree-order-3>

Searching or inserting inside a single node takes up to $O(m)$ time, since the keys are in a sorted array. That's fine! $m$ is a constant, and work inside a node is basically free compared to a seek. When we analyze a B-tree, the only thing we count is *seeks*, since each one costs millions of instructions and completely dominates everything else

=== Choosing $m$

$m$ is a design choice: we pick it so that one node fits exactly in whatever we get back from a single seek

- *Network* - Data is sent in packets of up to the *MTU* (maximum transmission unit), which is 1,500 bytes on basically everything modern. So we choose $m$ so that a node's keys fit in 1,500 bytes
- *Disk* - Disks read and write whole *blocks*, traditionally 512 bytes and nowadays often 4,096 bytes. Writing even 2 bytes uses up a whole block, so we choose $m$ so that a node fills one block

This works because almost all the time of a seek is spent *finding* the start of the data (something like 100 times longer than actually reading it). Once we've paid for the seek, reading a whole node full of keys costs almost nothing extra

== Inserting into a B-Tree

New keys are always inserted into a *leaf*. The only way a key ever ends up in an internal node is by being pushed up out of a leaf that got too full

To insert a key into a B-tree of order $m$

+ Starting at the root, find the child to go down into, just like a search: go to the left of the first key that is larger than the new key. An empty key slot acts like $infinity$, so if the new key is larger than every key in the node, go to the right of the last key
+ Repeat until we reach a leaf, and insert the key into the leaf's sorted array
+ If the leaf now has $m$ keys, it is *overfilled*, so we *split* it
  + Take the *middle* key and throw it up into the parent. If there is no parent, it becomes a brand new root
  + The keys smaller than the middle key become a node to its left, and the keys larger than it become a node to its right
+ If throwing the key up overfills the parent, split the parent the same way, and keep going up the tree as long as nodes overflow

Let's build a B-tree of order $m = 5$, so each node holds at most 4 keys. Inserting 1, 57, 3, and 101 just fills up the root: we insert each one into the sorted array, shifting keys over as needed (inserting 3 shifts 57 over). Inserting 21 makes the root overflow with 5 keys, so we split it: 21, the middle key, gets thrown up into a new root, with the smaller keys on its left and the larger keys on its right, like in @btree-first-split

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: horizon + center,
    btree(("1 3 21 57 101",)),
    $->$,
    btree(("21", "1 3", "57 101")),
    [Insert 21: 5 keys is too many], [], [Split: 21 goes up],
  ),
  caption: [Example: inserting 1, 57, 3, 101, then 21 into a B-tree of order 5. The fifth key overfills the root, so the middle key becomes a new root and the rest splits into two leaves],
) <btree-first-split>

Now we insert 102. The root isn't a leaf, so we don't insert there. 102 is not less than 21, but it is less than the empty slot after 21 ($infinity$), so we go to the right of 21 and insert into that leaf. Inserting 105 also fits. Inserting 109 overfills the leaf again, so we split it and throw 102 up into the root, giving us three leaves in @btree-second-split

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: horizon + center,
    btree(("21", "1 3", "57 101 102 105 109")),
    $->$,
    btree(("21 102", "1 3", "57 101", "105 109")),
    [Insert 102, 105, 109], [], [Split: 102 goes up],
  ),
  caption: [Example: inserting 102, 105, and 109. The right leaf overfills on 109, so 102 is thrown up into the root, which now has two keys and three children],
) <btree-second-split>

A split can cascade all the way up. In the B-tree of order 3 at the top of @btree-cascade, each node holds at most 2 keys. To insert 79, we go right of 42 and land in the leaf with 43 and 55, which overfills. 55 gets thrown up into the root, but that overfills the root too, so we split the root as well: 42 becomes the new root, and 55 keeps the two halves of the old leaf as its children

#figure(
  grid(
    columns: 1,
    row-gutter: 1em,
    align: center,
    btree(("23 42", "10", "30", "43 55 79")),
    $arrow.b$ + [ 55 goes up],
    btree(("23 42 55", "10", "30", "43", "79")),
    $arrow.b$ + [ 42 goes up],
    btree(("42", ("23", "10", "30"), ("55", "43", "79"))),
  ),
  caption: [Example: inserting 79 into a B-tree of order 3. The leaf overfills, so 55 moves up, which overfills the root, so 42 moves up into a new root, making the tree one level taller],
) <btree-cascade>

If $m$ is even, an overfilled node has an even number of keys, so there is no single middle key. Pick either one (taking the floor or the ceiling of the middle index); it just biases the tree slightly to the left or right and doesn't change the analysis. In general, we choose an odd $m$ because it makes the middle obvious

We won't cover removing from a B-tree. It makes the code a lot more complicated without changing any of the interesting ideas, so our B-trees only support `insert` and `find`

== Properties of B-Trees

These are true of every B-tree of order $m$

- *All leaves are at the same depth.* The tree only ever grows taller when the root splits and a new root is created above it, which pushes every leaf down by one level at the same time
- *The root can have as few as 1 key*
- *Every non-root node has at least $ceil(m / 2) - 1$ keys.* A non-root node can only come into existence by splitting an overfilled node of $m$ keys. One key goes up, and the other $m - 1$ are split into two halves, so the smaller half has $floor((m - 1) / 2) = ceil(m / 2) - 1$ keys. For $m = 5$, both halves get 2 keys. For $m = 4$, one half gets 1 key and the other gets 2
- *Every non-root internal node has at least $ceil(m / 2)$ children*, since a node with $k$ keys has $k + 1$ children

These properties also let us figure out what order a B-tree could be. A single node can't tell us much: a leaf with 2 keys could come from $m = 5$ or $m = 6$, since splitting an overfilled node of 6 keys leaves 3 and 2. But the structure of the whole tree can rule options out, since each part had to be produced by splits of the same order

== Searching a B-Tree

Searching works the same way as finding where to insert

+ Find the first index $i$ in the node whose key is *not smaller* than the key we're looking for. If we run out of keys, $i$ is one past the last key
+ If $i$ is a valid index and the key there is the one we want, we found it
+ Otherwise, if the node is a leaf, the key isn't in the tree
+ Otherwise, fetch child $i$ (the child to the left of key $i$) and search it recursively

For example, to find 101 in the tree from @btree-second-split, we stop at index 1 of the root, since 102 is the first key not smaller than 101. 101 isn't 102, and the root isn't a leaf, so we fetch child 1, the leaf with 57 and 101, and find it there

The code for `_exists` is shown below. It is intentionally written tersely, so it's worth working through carefully

```cpp
// BTree.hpp

/** Returns whether `key` is in the subtree rooted at `node`
 * Runtime: O(log_m n) seeks, plus O(m) work inside each node
 */
template <typename K>
bool BTree<K>::_exists(BTreeNode& node, const K& key) {
    unsigned i;
    // find the index of the key, or the first index with a larger key
    for(i = 0; i < node.keys_ct_ && key > node.keys_[i]; i++) { }

    // the key is in this node
    if(i < node.keys_ct_ && key == node.keys_[i]) {
        return true;
    }

    // a leaf has no children left to search, so the key isn't in the tree
    if(node.isLeaf()) {
        return false;
    } else {
        // the expensive part: a seek to fetch the next node from disk or another server
        BTreeNode nextChild = node._fetchChild(i);
        return _exists(nextChild, key);
    }
}
```

- The `for` loop has an empty body. It keeps incrementing `i` as long as there are keys left in the node *and* our key is larger than the key at `i`. When it stops, `i` is either the index of our key, or the first index with a larger key
- `i < node.keys_ct_` is checked first, so if `i` ran past the last key, the `&&` short-circuits and we never read past the end of the array. In practice, we'd return the value stored at index `i` instead of just `true`
- A node is a leaf if it has no children. If a node has any children at all, it has a child to the left of key 0, so `isLeaf` just checks whether that first child pointer is null
- `_fetchChild` is where the seek happens: it asks the disk or the database for the next node. Every other line runs on a node we already have, so the cost of a search is the number of seeks, which is the height of the tree
