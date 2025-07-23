
# Module 10 - Tree Searching

A **traversal** is an algorithm that goes through every single node in a tree and visits it ($O(n)$ time)

A **search** is an algorithm that finds a node in a tree of value $v$ if it exists (worst case is when $v \notin T$, where $T$ represents any tree; this involves running the full traversal, so it is in $O(n)$ time)

Previously, we discussed two types of search **Breath First** and **Depth First** (**BFS** and **DFS**)

**BFS** is the same as level order traversal, where its overhead (or space complexity) is the maximum number of nodes in a queue (can also be seen as the width of a tree)

**DFS** involves any of the three traversals that descend into the tree's children: pre order traversal, in order traversal, and post order traversal. Its overhead is the maximum depth in the tree (or simply height)

BFS is more **reliable** than DFS. This is because it will eventually find a solution to a valid search if one exists, even if the tree is infinite in depth. Since BFS explores nodes level by level, this guarantees that all nodes at depth $d$ are visited before any node at depth $d + 1$. So if the solution lies at a shallow depth, BFS will find it eventually. 

In contrast, DFS can get **"stuck"** going down an infinite branch of a tree, especially if the solution lies on a different, shallower path. Therefore, DFS might never return a proper solution, even if it does exist.

So BFS will always work, but it might an infinite amount of memory. In fact, BFS uses more memory than DFS because it stores all the nodes at a particular width (one entire level in a queue). If the tree is very wide, then this would inv






<!--stackedit_data:
eyJoaXN0b3J5IjpbMTUxNTgyMjQwMywtMTU1MTMwNjM5NCwtOT
ExNjk1MTg4LC0xNTA5MzUyNjddfQ==
-->