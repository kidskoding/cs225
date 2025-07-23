
# Module 11 - BST and BST Implementation

Recall that all trees have **structure**. Fundamentally, a tree gives us **positions** that when we put nodes in a tree, we put them in a position. Previously, the trees we discussed were in a position that had no meaning whatsoever. Is there a way for us to put nodes in a specific position that has meaning?

For this to take place, we need to discuss a different type of tree: the **Binary Search Tree**, or BST. The BST has a property, in which a node's left subtree contains nodes with keys less than the node's key and a node's right subtree contains nodes with keys greater than the node's key.

Mathematically speaking, for tree $T$ to be a BST:
$T = \empty$, $T = (r, T_L, T_R)$, where $x \in T_L$, in which $x < r$, where $x$ is a value in $T_R$ where $x > r$
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTU2MzY5OTA1MywtNDc1NzYyNTkxLC03Mj
I0MDU5NDVdfQ==
-->