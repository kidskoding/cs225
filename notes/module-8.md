
# Module 8 - Trees

A **tree** comprises of two things:
1. Its an acyclic graph (has no cycles)
2. It is connected, meaning that there is a unique path from the root to every other node 

A **binary tree**, $T$, is either 
1. A tree composed of a tuple containing the **root**, **left subtree**, and **right subtree**, $T = (r, T_L, T_R)$
2. A **null** tree (there are no nodes in the tree)

A data structure should be able to contain nothing because that is how we tend to start evolving and adding elements/nodes into it. In the context of a tree, we would like to be able to start it off with nothing. Therefore, it makes sense to define a binary tree as a **null** tree, where it has no vertices
<!--stackedit_data:
eyJoaXN0b3J5IjpbMjEyNTAwNjI1LC0yOTE4ODQxNzddfQ==
-->