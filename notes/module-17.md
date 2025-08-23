
# Module 17 - BTrees

In Big-O, we assume that we have uniform time for all operations, but this is not always the case

Sometimes, searching, inserting, and deleting data in a AVL tree is not always efficient when when working with disks, where access is much slower than in memory

A **B-Tree** is a self-balancing search tree designed for efficient storage and retrieval on disks. Unlike a binary search tree that stores only one key per node, each B-Tree node can hold multiple keys and have multiple children
- The keys inside a node are kept in **sorted order**, and the children split the key ranges between them
- All leaves appear at the same depth, so the tree remains balanced
- Because each node can hold many keys (often filling a disk block), the tree height is very small, which reduces disk accesses
- Operations like search, insertion, and deletion still take **$O(\log n)$** time, but with a much smaller constant factor, making B-Trees ideal for databases and file systems
<!--stackedit_data:
eyJoaXN0b3J5IjpbNjc5OTc4MTk0LC0xNDcwOTAwMDM3XX0=
-->