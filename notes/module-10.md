
# Module 10 - Tree Searching

A **traversal** is an algorithm that goes through every single node in a tree and visits it ($O(n)$ time)

A **search** is an algorithm that finds a node in a tree of value $v$ if it exists (worst case is when $v \notin T$, where $T$ represents any tree; this involves running the full traversal, so it is in $O(n)$ time)

Previously, we discussed two types of search **Breath First** and **Depth First** (**BFS** and **DFS**)

**BFS** is the same as level order traversal, where its overhead (or space complexity) is the maximum number of nodes in a queue (can also be seen as the width of a tree)

**DFS** involves any of the three traversals that descend into the tree's children: pre order traversal, in order traversal, and post order traversal. Its overhead is the maximum depth in the tree (or simply height)

BFS is more **reliable** than DFS. This is because it will eventually find a solution to a valid search if one exists, even if the tree is infinite in depth. Since BFS explores nodes level by level, this guarantees that all nodes at depth $d$ are visited before any node at depth $d + 1$. So if the solution lies at a shallow depth, BFS will find it eventually. 

In contrast, DFS can get **"stuck"** going down an infinite branch of a tree, especially if the solution lies on a different, shallower path. Therefore, DFS might never return a proper solution, even if it does exist.

BFS will always find a solution if one exists, even in infinite-depth trees, but it may require an infinite amount of memory. This is because BFS stores all nodes at a given depth (one full level of the tree) in a queue before moving on to the next level. If the tree is very wide, this means the queue can grow extremely large, consuming a lot of memory. 

In contrast, DFS typically uses less memory, since it only needs to store the current path from the root to a leaf, which depends on the depth of the tree, not its width.

Therefore, in any practical application, memory is going to be the forefront problem. Since DFS uses less memory, that will often be the best approach. But, if there are infinite trees, DFS wouldn't work. There is a solution that solves this problem and it is known as **iterative deepening**

**Iterative Deepening** runs DFS with a **maximum depth limit** of $k$, meaning it will not explore any nodes beyond depth $k$ (starting at $k = 0$). When DFS reaches that depth, it stops descending and backtracks up the tree. This approach is useful because the maximum memory used when doing DFS is proportional to $k$ (simply the overhead cost - $O(k)$). If no solution is found at depth $k$, the algorithm restarts DFS with a new depth limit $k+1$, and this process repeats until a solution is found.

This effectively simulates BFS for DFS and will always find the solution because it explores each node at every level by using bounded memory (as deep as depth $k$ with overhead cost of $O(k)$). 

These are the two basic searching strategies, but they aren't that effective, since they can be slow in both time and memory. But what if there was a data structure that put searching at its forefront, which is essentially what a **map** or **dictionary** does




<!--stackedit_data:
eyJoaXN0b3J5IjpbNTgwNTM1NzE4LC0xNTUxMzA2Mzk0LC05MT
E2OTUxODgsLTE1MDkzNTI2N119
-->