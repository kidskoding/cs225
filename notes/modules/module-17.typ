#import "../diagrams.typ": btree

= BTrees

In Big-O, we assume that we have uniform time for all operations, but this is not always the case

Sometimes, searching, inserting, and deleting data in a AVL tree is not always efficient when working with disks, where access is much slower than in memory

A *B-Tree* is a self-balancing search tree designed for efficient storage and retrieval on disks. Unlike a binary search tree that stores only one key per node, each B-Tree node can hold multiple keys and have multiple children

- The keys inside a node are kept in *sorted order*, and the children split the key ranges between them
- All leaves appear at the same depth, so the tree remains balanced
- Because each node can hold many keys (often filling a disk block), the tree height is very small, which reduces disk accesses
- Operations like search, insertion, and deletion still take *$O(log n)$* time, but with a much smaller constant factor, making B-Trees ideal for databases and file systems

Take the small B-tree in @btree-order-3: its root holds two keys, 20 and 40, which split its three children by range.

#figure(
  btree(("20 40", "5 10", "25 30", "50 60")),
  caption: [Example: a B-tree of order 3. Each node holds at most 2 sorted keys, the keys 20 and 40 split the children into $< 20$, between 20 and 40, and $> 40$, and every leaf is at the same depth],
) <btree-order-3>

When an insertion fills a node past its capacity, the node splits, like in @btree-insert-split, where 27 overflows the leaf and gets pushed up into the root.

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: horizon + center,
    btree(("20", "5 10", "25 27 30")),
    $->$,
    btree(("20 27", "5 10", "25", "30")),
    [Insert 27 into the leaf 25 30], [], [Split: 27 moves up],
  ),
  caption: [Example: inserting 27 into a B-tree of order 3. The leaf overflows to three keys, so its middle key moves up into the parent and the leaf splits in two],
) <btree-insert-split>
