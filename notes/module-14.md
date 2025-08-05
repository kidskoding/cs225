
# Module 14 - AVL Trees

**AVL trees** are **self-balancing binary search trees** that automatically keep themselves balanced through rotations after insertions and deletions, ensuring efficient operations

This means that we have to consider 3 things:

- Rotations
- Maintaining Height
- Detecting Imbalance - check subtree height in $O(1)$ time and compute balance in $O(1)$ time

We can compute balance by having each subtree store its height, which means that I can retrieve it in constant time

**Recognize the patterns to figure out which rotation to use**

If insertion occurred on a tree, $t$, where a **"right stick"** formed (two consecutive right children and no left children), meaning that its right subtree was heavier, we would need to do a **L** rotation about $t$ to restore the balance of the tree

$h = x$ prior to the left rotation and is now $h = x + 1$, where $x$ is the height of the right subtree

We leverage this by noting that the balance factor, $b$ of `t->right` is 2, which is greater than 0 (`t->right > 0`) 

If insertion occurred on a tree, $t$, where a **"right elbow"** formed, we would need to do a **RL** rotation about $t$ to restore the balance of the tree

<!--stackedit_data:
eyJoaXN0b3J5IjpbMTQ0MjU4NTQwMSwxMjk0NDE2NzgwLDExMD
k5Nzg2MjgsLTE2NTg4NDE0ODIsNDA5NTc4MTM4LC00MDk2MzI1
OTFdfQ==
-->