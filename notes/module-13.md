
# Module 13 - BST Rotations

A **BST rotation** is a strategy to help change the structure of a BST to help **rebalance** the tree without violating the BST property.

Two key details:

1. Maintain the BST property
	- `node->left < root`
	- `node->right > root`
2. Change a "stick" (every node basically has only one child) into a "mountain" (roughly equal subtrees)

When a BST becomes very imbalanced, where there are plenty of more nodes on one side than another, you can perform **rotations** to rebalance it by redistributing nodes so that the left and right subtrees are more evenly balanced (this is how "sticks" turn into "mountains")

Rotations:

- **Rotate nodes around a pivot** to “move” some nodes from the heavier side with more nodes to the lighter side with less nodes
-   After rotation, the tree height decreases or the balancing improves
-   The goal is to **evenly split nodes** (or get as close as possible) between left and right subtrees at that pivot node

For example, if the left subtree is much taller than the right, a right rotation can lift the left child up and move the original root down to the right subtree, balancing nodes between the two sides.


<!--stackedit_data:
eyJoaXN0b3J5IjpbMTYzNzU5MTY4MSwtMjg3MjM4MDIsMzMwNT
cwNzQ0XX0=
-->