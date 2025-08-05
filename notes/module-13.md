
# Module 13 - BST Rotations

A **BST rotation** is a strategy to help change the structure of a BST to help **rebalance** the tree without violating the BST property.

Two key details:

1. Maintain the BST property
	- `node->left < root`
	- `node->right > root`
2. Change a "stick" (every node basically has only one child) into a "mountain" (roughly equal subtrees)

When a BST becomes very imbalanced, where there are plenty of more nodes on one side than another, you can perform **rotations** to rebalance it by redistributing nodes so that the left and right subtrees are more evenly balanced (this is how "sticks" turn into "mountains")

### What rotations do:
-   **Rotate nodes around a pivot** to “move” some nodes from the heavier (taller) side to the lighter side.
    
-   After rotation, the tree height decreases or the balance factor improves.
    
-   The goal is to **evenly split nodes** (or get as close as possible) between left and right subtrees at that pivot node.


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE5OTQyNjM5NTUsLTI4NzIzODAyLDMzMD
U3MDc0NF19
-->