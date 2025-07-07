
# Module 8 - Trees

A **tree** comprises of two things:
1. Its an acyclic graph (has no cycles)
2. It is connected, meaning that there is a unique path from the root to every other node 

A **binary tree**, $T$, is either 
1. A tree composed of a tuple containing the **root**, **left subtree**, and **right subtree**, $T = (r, T_L, T_R)$, where $r, T_L,$ and $T_R$ represent the root, left subtree, and right subtree respectively
2. A **null** tree (there are no nodes in the tree)

A data structure should be able to contain nothing because that is how we tend to start evolving and adding elements/nodes into it. In the context of a tree, we would like to be able to start it off with nothing. Therefore, it makes sense to define a binary tree as a **null** tree, where it has no vertices

A tree's **height**, height($T$), is the shortest path from the roof to a leaf. However, this changes a little bit for a binary tree

In a binary tree, its height works a little bit differently. It isequal to maximum subtree of the left and right plus 1, or simply max($T_L$, $T_R$) + 1

This is because 

The height of a null tree is simply -1
<!--stackedit_data:
eyJoaXN0b3J5IjpbNTEzODQwODc4LDIxMjUwMDYyNSwtMjkxOD
g0MTc3XX0=
-->