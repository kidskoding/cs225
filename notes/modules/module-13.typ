#import "../diagrams.typ": steps, tree

= BST Rotations

A *BST rotation* is a strategy to help change the structure of a BST to help *rebalance* the tree without violating the BST property.

Two key details:

+ Maintain the BST property
  - `node->left < root`
  - `node->right > root`
+ Change a "stick" (every node basically has only one child) into a "mountain" (roughly equal subtrees)

When a BST becomes very imbalanced, where there are plenty of more nodes on one side than another, you can perform *rotations* to rebalance it by redistributing nodes so that the left and right subtrees are more evenly balanced (this is how "sticks" turn into "mountains")

Rotations:

- *Rotate nodes around a pivot* to “move” some nodes from the heavier side with more nodes to the lighter side with less nodes
- After rotation, the tree height decreases or the balancing improves
- The goal is to *evenly split nodes* (or get as close as possible) between left and right subtrees at that pivot node

For example, if the left subtree is much taller than the right, a right rotation can lift the left child up and move the original root down to the right subtree, balancing nodes between the two sides, like the R rotation in @rotation-right-example, where 4 becomes the new root and its old right child 5 moves over to 6.

#figure(
  steps((6, (4, (2, 1, 3), 5), 7), (4, (2, 1, 3), (6, 5, 7)), highlight: (5,)),
  caption: [Example: an R rotation about 6. Node 4 moves up, 6 moves down to the right, and 4's right subtree (5) is handed over to become 6's left subtree],
) <rotation-right-example>

There are a total of *four* rotations: L (left), R (right), LR (left-right), RL (right-left)

- *L* (Left Rotation) - used when the right subtree is too tall and forms a *"right stick"* (due to its shape). This is known formally as the Right-Right case
- *R* (Right Rotation) - used when the left subtree is too tall and forms a *"left stick"* (due to its shape). This is known formally as the Left-Left case
- *LR* (Left-Right Rotation) - Used when there's imbalance in the left-right direction and forms a *"left elbow"* (due to its shape). This is known formally as the Left-Right case, where the left child has a taller right subtree
  - Perform a *left* and then *right* rotation
- *RL* (Right-Left Rotation) - Used when there's imbalance in the right-left direction and forms a *right elbow* (due to its shape). This is known formally as the Right-Left case, where the right child has a taller left subtree
  - Perform a *right* and then *left* rotation

If you're having trouble picturing these shapes, @rotation-four-shapes draws all four with just three nodes, labeled with the rotation that fixes each one.

#figure(
  grid(
    columns: 4,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: center,
    tree((3, (2, 1, none), none)),
    tree((1, none, (2, none, 3))),
    tree((3, (1, none, 2), none)),
    tree((1, none, (3, 2, none))),
    [Left stick (R)], [Right stick (L)], [Left elbow (LR)], [Right elbow (RL)],
  ),
  caption: [The four imbalanced shapes and the rotation that fixes each],
) <rotation-four-shapes>

Other things to know about rotations:

- All rotations are local, meaning subtrees aren't impacted
- All rotations are constant time, $O(1)$ because they only rearrange a *fixed, small number of pointers* (either a node, its child, and their subtrees); the amount of work doesn’t grow with the size of the tree
- The BST property is maintained

The goal is to get $h equiv O(log n)$. These types of trees are called *Adelson-Velsky Landis trees* (or AVL trees for short), which are a specific type of *BBST* (Balanced Binary Search Tree)
