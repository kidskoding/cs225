
# Module 13 - BST Rotations

A **BST rotation** is a strategy to help change the structure of a BST to help **rebalance** the tree without violating the BST property.

Two key details:

1. Maintain the BST property
	- `node->left < root`
	- `node->right > root`
2. Change a "stick" (every node basically has only one child) into a "mountain" (roughly equal subtrees)

If a tree is very imbalanced, we can do a rotation where 
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTIzOTA1NTI3NCwzMzA1NzA3NDRdfQ==
-->