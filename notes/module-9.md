
# Module 9 - Tree Traversals

Previously, we discussed a new data structure: trees, where we discussed that there is a $O(n)$, linear space, overhead cost because $n$-space is required to store the data

Here, we will continue discussing Trees and the Tree ADT. Previously, we failed to discuss how the implementation of `insert`, `remove`, and `access` would work. This is because the way they work is different for every tree.

Recall that previously we discussed that every data structure should be able to have its own way of getting everything it contains, which was done through an iterator. This means that if we want to achieve this functionality, we would need to implement an iterator interface. But **how**?

We need to know how to find everything in our tree. Otherwise, how would we know that we found everything. The simple answer to these questions is by implementing **tree traversals**

**Tree traversals** are algorithms that will follow the structure of a tree in some fixed order that **visits** every node. They access **all the nodes** in a tree. So every data point is stored in some sort, and we are going to visit all of the nodes.
- By visit, we typically mean whatever the algorithm wants to do with the data, which for demonstration purposes, we just simplify to printing the data because that is an easy way to test what is going on
- So when a node is visited, it will then be print and then at the end check whether we went through every node in the tree

While it makes sense that the goal of a tree traversal is to visit every node, but **how**? Should a tree visit a node **before** I traverse into the subtree, **in between** the subtree, or **after** the subtree? 

The simple answer is that **it's up to you**. It depends on **when** you choose to visit a node in relation to its children. These three choices correspond to the three well-known tree traversal techniques:

 - **Pre-order traversal** – visit the node **before** its subtrees
  -   **In-order traversal** – visit the node **between** its subtrees
  -   **Post-order traversal** – visit the node **after** its subtrees

By understanding how these traversals work, it makes coding them much more simple and straight forward.

1. Start from the root and do one of three of the following options (the order in which you do the tree depends on the traversal type)
	- Visit
	- Descend into the left subtree
	- Descend into the right subtree
2. Repeat step 1 for the **next** subtree (depending on its left or right right) until there is no subtree available

The order in which you do the three options above depends on the traversal type
- **Preorder** - visit, decend left, decend right
- **Inorder** - decend left, visit, decend right
- **Postorder** - decend left, decend right, visit

Traversals are **recursive** by nature because trees are recursive data structures. When we visit a node, we then descend into its left and right subtrees, and for each of those, we repeat the same process: visiting the node and then exploring its subtrees. This pattern continues until we reach nodes with no children, making recursion the best way to mimic this behavior.

### Pre Order traversal

Preorder traversal visits a tree node, and then decends into the left and right subtrees. Its recursive since trees are recursive data structures in nature.

This makes coding pre order traversal very simple. This function will take in the current `TreeNode` being processed (`curr`): ``void  preOrderTraversal(TreeNode*  curr)``;

This will follow 3 simple steps:
1. Visit the current tree node (which in our case is printing its data)
2. Recursive call preorder on the left subtree
3. Recursive call preorder on the right subtree

The code for `preOrderTraversal` shown below

```
template <typename T>
void BinaryTree<T>::preOrderTraversal(TreeNode* curr) {
    if(curr == nullptr) { return; }

    std::cout << curr->data << std::endl;
    preOrderTraversal(curr->left);
    preOrderTraversal(curr->right);
}
```

Our **base case** occurs when the current node pointer (`curr`) is `nullptr`. This means we've reached a point in the tree where no further nodes exist (i.e., a leaf's child), so there's nothing to process or recurse on — we simply return.

If the node is not `nullptr`, we proceed with the pre-order traversal steps:

1.  **Visit the current node** — we process its data (e.g., print it).
2.  **Traverse the left subtree** — recursively call `preOrderTraversal` on `curr->left`.
3.  **Traverse the right subtree** — recursively call `preOrderTraversal` on `curr->right`.

Each of these recursive calls follows the same pattern: check if the node is `nullptr`, visit it, and recurse on its children. This process naturally continues until all nodes have been visited, and both left and right child pointers are `nullptr`, causing the recursion to unwind.

### In Order traversal

Inorder traversal decends into the left sub visits a tree node, and then decends into the left and right subtrees. Its recursive since trees are recursive data structures in nature.
<!--stackedit_data:
eyJoaXN0b3J5IjpbNTM5Mjg0NDUsLTU0MzYyMjAxOCwtNTk3NT
E0Mzc5LDU2NTg4NTI5NSwtMTY0NjQ3OTQzNiwtMTQ3MjYxNTM0
OCwtNzE3OTA2NTksOTcwODg1Njk0LDEzMDM5MjA2NTYsNjY1OT
k5NzkyLC02NjExMjU0NjBdfQ==
-->