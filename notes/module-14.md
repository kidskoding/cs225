
# Module 14 - AVL Trees

**AVL trees** are **self-balancing binary search trees** that automatically keep themselves balanced through rotations after insertions and deletions, ensuring efficient operations

This means that we have to consider 3 things:

- Rotations
- Maintaining Height
- Detecting Imbalance - check subtree height in $O(1)$ time and compute balance in $O(1)$ time

We can compute balance by having each subtree store its height, which means that I can retrieve it in constant time

If insertion occurred on a tree, $t$, where its right subtree was heavier, we would need to do a **L** rotation about $t$ to restore the balance of the tree. 

We leverage this by noting that the balance factor of `t->right` is greater than 0 (`t->right > 0`) 

<!--stackedit_data:
eyJoaXN0b3J5IjpbNjA2ODAyMjkzLDEyOTQ0MTY3ODAsMTEwOT
k3ODYyOCwtMTY1ODg0MTQ4Miw0MDk1NzgxMzgsLTQwOTYzMjU5
MV19
-->