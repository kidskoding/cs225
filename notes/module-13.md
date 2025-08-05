
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

There are a total of **four** rotations: L (left), R (right), LR (left-right), RL (right-left)

- **L** (Left Rotation) - used when the right subtree is too tall and forms a **"right stick"** (due to its shape). This is known formally as the Right-Right case
- **R** (Right Rotation) - used when the left subtree is too tall and forms a **"left stick"** (due to its shape). This is known formally as the Left-Left case
- **LR** (Left-Right Rotation) - Used when there's imbalance in the left-right direction and forms a **"left elbow"** (due to its shape). This is known formally as the Left-Right case, where the left child has a taller right subtree
	- Perform a **left** and then **right** rotation
- **RL** (Right-Left Rotation) - Used when there's imbalance in the right-left direction and forms a **right elbow** . Referred to as **"right elbow"** (due to its shape)
	- Perform a **right** and then **left** rotation

Other things to know about rotations:
- All rotations are local, meaning subtrees aren't impacted
- All rotations are constant time, $O(1)$ because they only rearrange a **fixed, small number of pointers** (either a node, its child, and their subtrees); the amount of work doesn’t grow with the size of the tree
- The BST property is maintained

The goal is to get $h \equiv O(\log n)$. These types of trees are called **AVL trees** (named after Georgy Addison-Velsky and Evengii Landis), which are a specific type of **BBST** (Balanced Binary Search Tree)
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEyNTk5NDQwNzYsNTUxNTQwNzM1LC0xMj
g3NjczMTg5LDE2NzA5MTYzNDMsLTQyMDU5MjYwLDE2Mzc1OTE2
ODEsLTI4NzIzODAyLDMzMDU3MDc0NF19
-->