
# Module 14 - AVL Trees

**AVL trees** are **self-balancing binary search trees** that automatically keep themselves balanced through rotations after insertions and deletions, ensuring efficient operations

This means that we have to consider 3 things:

- Rotations
- Maintaining Height
- Detecting Imbalance - check subtree height in $O(1)$ time and compute balance in $O(1)$ time

We can compute balance by having each subtree store its height, which means that I can retrieve it in constant time

**Recognize the patterns to figure out which rotation to use**

If insertion occurred on a subtree, $t$, where a **"right stick"** formed (two consecutive right children and no left children), meaning that its right subtree was heavier, we would need to do a **L** rotation about $t$ to restore the balance of the tree

$h = x$ prior to the left rotation and is now $h = x + 1$, where $x$ is the height of the right subtree

We leverage this by noting that the balance factor, $b$ of `t->right` is 2, which is greater than 0 (`t->right > 0`) 

If insertion occurred on a subtree, $t$, where a **"right elbow"** formed (right child has taller left subtree), we would need to do a **RL** rotation about $t$ to restore the balance of the tree

We leverage this by noting that the balance factor, $b$ of `t->right` is -1, which is less than 0 (`t->right < 0`) 

The opposites are true for a **"left stick"** and **"left elbow"**, where we would need **R** and **LR** rotations respectfully

## Insertion into an AVL tree

With the knowledge in BST rotations, to insert a node into an AVL tree, we know we have to do the following steps

1. Insert at proper place
2. Check for imbalance
3. Rotate, if necessary
4. Update height


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTcxMTI2NDI2MiwxMzg3ODAzOTQxLDEyOT
Q0MTY3ODAsMTEwOTk3ODYyOCwtMTY1ODg0MTQ4Miw0MDk1Nzgx
MzgsLTQwOTYzMjU5MV19
-->