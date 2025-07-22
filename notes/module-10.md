
# Module 10 - Tree Searching

A **traversal** is an algorithm that goes through every single node in a tree and visits it ($O(n)$ time)

A **search** is an algorithm that finds a node in a tree of value $v$ if it exists (worst case is when $v \notin T$, where $T$ represents any tree; this involves running the full traversal so it is in $O(n)$ time)

Previously, we discussed two types of search **Breath First** and **Depth First** (BFS and DFS)

**BFS** is the same as level order traversal, where its overhead (or space complexity) is the maximum number of nodes in a queue (can also be seen as the width of a tree)

**DFS** involves any of the three traversals that descend into the tree's children: pre order traversal, in order traversal, and post order traversal. Its overhead is the maximum depth in the tree (or simply height)





<!--stackedit_data:
eyJoaXN0b3J5IjpbLTkxMTY5NTE4OCwtMTUwOTM1MjY3XX0=
-->