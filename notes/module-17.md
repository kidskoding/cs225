
# Module 17 - BTrees

In Big-O, we assume that we have uniform time for all operations, but this is not always the case

Sometimes, the need to make searching, inserting, and deleting data efficient when working with disks, where access is much slower than in memory

A **B-Tree** is motivated by the need to make searching, inserting, and deleting data efficient when working with disks, where access is much slower than in memory. Regular binary trees are too tall, requiring many disk reads, but a B-Tree stores multiple keys per node and allows many children, making the tree much shallower. Each node is designed to fit in a disk block, so finding a key usually takes only a few disk accesses instead of many. This makes B-Trees ideal for databases and file systems, where minimizing disk I/O is critical.
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE5MjQ1MTgyODYsLTE0NzA5MDAwMzddfQ
==
-->