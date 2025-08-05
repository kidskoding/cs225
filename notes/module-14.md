
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

We already established that we need each `TreeNode` in an AVL tree to track its height. Therefore,

```
struct TreeNode {
    K key;
    V value;

    // have each `TreeNode` store the height in order to self balance
    unsigned int height;

    TreeNode* left;
    TreeNode* right;
};
```

Inserting a node into an AVL tree is very similar to a BST (since it is in fact a type of BST!)

```
template <typename K, typename V>
void AVL<K, V>::_insert(const K& key, const V& value, TreeNode*& curr) {
    if(curr == nullptr) { return curr; } 
    
    // maintain BST property
    if(curr->key > key) { return _insert(key, value, curr->right);  }
    if(curr->key < key) { return _insert(key, value, curr->left); }

    // ensure the balance of the AVL tree
}

template <typename K, typename V>
void AVL<K, V>::insert(K key, V value) {
    _insert(key, value, root);
    node_map[key] = value;
}
```

The code above ensures the AVL tree maintains BST properties by descending into the left subtree if the key is smaller and descending into the right subtree if the key is greater

However, we are missing one crucial detail: ensuring that the AVL tree is **balanced**. To do this, we need to calculate the **balance factor** and then based on the balance factor, perform the appropriate rotation

The balancing function is shown below

```
template <typename K, typename V>
void AVL<K, V>::_ensureBalance(TreeNode*& curr) {
    // calculate the balance factor
    int balance = height(curr->right) - height(curr->left);

    // check if the node is currently not in balance
    if(balance == -2) { // heavy left ("left stick" shaped subtree)
        int leftBalance = height(curr->left->right) - height(curr->left->left);
        if(leftBalance == -1) {
            // perform right rotation
        } else {
            // perform left-right rotation
        }
    } else if(balance == 2) { // heavy right ("right stick" shaped subtree)
        int rightBalance = height(curr->right->right) - height(curr->right->left);
        if(rightBalance == -1) {
            // perform left rotation
        } else {
            // perform right-left rotation
        }
    }

    _updateHeight(curr);
}
```

This is a lot of code, but what we are essentially doing is calculating the balance factor so we know which rotation to perform!

Compute the balance of the tree to determine the shape of a stick

- If the balance is -2, we know that the shape of the left subtree is either a **"left stick"** or **"left elbow"**
	- We then need to compute the balance of the left subtree to figure out specifically which one it is
	- A left subtree balance of -1 means that its a **"left stick"**, so we need to do a **right rotation**
	- A left subtree balance of +1 means that its a **"left elbow"**, so we need to do a **left-right rotation**
- Similarly, if the balance is +2, we know that the shape of the right subtree is either a **"right stick"** or **"right elbow"**
	- We then need to compute the balance of the right subtree to figure out specifically which one it is
	- A right subtree of balance -1 means that its a **"right stick"**, so we need to do a **left rotation**
	- A right subtree balance of +1 means that its a **"right elbow"**, so we need to do a **right-left** rotation

We need a helper height function in order to avoid any crashes. While `curr->left->height` and `curr->right->height` do work, they may crash if `curr->left` and `curr->right` are null. 

Therefore, a helper function to get the height of a node can help prevent any unecessary crashes. It simply checks if the node is not null before calling its height property. The code is shown below

```
template <typename K, typename V>
int AVL<K, V>::height(TreeNode* node) { 	
	  return node != nullptr ? 0 : node->height; 
}
```

We also need a helper function to update the height after performing necessary rotations


The updated node's height is 1 plus the max height of its left and right subtrees 

Height represents the number of edges in the longest path from that node down to a leaf. When calculating this longest path, you need to consider that it will go through either the left subtree or the right subtree, depending on whichever is taller. This is the performed by taking the maximum height between the two subtrees

However, to get the total path length from the current node, you must add one additional edge, because that accounts for descending into the taller subtree

```
template <typename K, typename V>
void AVL<K, V>::_updateHeight(TreeNode* curr) {
    // calculate height as 1 + maximum height of children
    // the +1 accounts for the extra edge needed to descend into the subtree with a greater height
    // this works after any tree modification because height depends on the current tree structure
    if(curr != nullptr) {
        curr->height = 1 + std::max(height(curr->left), height(curr->right));
    }
}
```

From here, the rest is simple. We just have to simply code each rotation. The rotations intuitively make sense to code if you know what's going on

1. **Left Rotation**
	- The right child becomes the new root of the subtree
	- The new root's left subtree becomes the old root's right child
	- The old root becomes the left child of the new root of the subtree
2. **Right Rotation**
	- The left child becomes the new root of the subtree
	- The new root's right subtree becomes the old root's left child
	- The old root becomes the right child of the new root of the subtree
3. **Left-Right Rotation**
	- Perform a left rotation
	- Perform a right rotation
4. **Right-Left Rotation**
	- Perform a right rotation
	- Perform a left rotation

Coding these then becomes easy

```
template <typename K, typename V>
void AVL<K, V>::_rotateLeft(TreeNode*& root) {
    // the right child becomes the new root
    TreeNode* newRoot = root->right;

    // move `newRoot`'s left subtree to old root's right subtree
    root->right = newRoot->left;

    // the old root becomes the left child of the new root
    newRoot->left = root;

    // update pointer to point to the new root
    root = newRoot;
}
```
```
template <typename K, typename V>
void AVL<K, V>::_rotateRight(TreeNode*& root) {
    // the left child becomes the new root
    TreeNode* newRoot = root->left;

    // move `newRoot`'s right subtree to old root's left subtree
    root->left = newRoot->right;

    // the old root becomes the right child of the new root
    newRoot->right = root;

    // update pointer to point to the new root
    root = newRoot;
}
```

```
template <typename K, typename V>
void AVL<K, V>::_rotateLeftRight(TreeNode*& root) {
    // rotate left and then rotate right
    _rotateLeft(root);
    _rotateRight(root);
}
```

```
template <typename K, typename V>
void AVL<K, V>::_rotateRightLeft(TreeNode*& root) {
    // rotate right and then rotate left
    _rotateRight(root);
    _rotateLeft(root);
}
```

## AVL Tree Analysis

`insert`, `remove`, and `find` also all run in $O(h)$. Recall that this is because in the worst case, we may need to traverse from the root down to a leaf node, visiting $h + 1$ nodes.

However, we will now argue that $h = O(\log n)$, using the balance property to prove this

Recall from discrete math, the definition of big-O states that $f(n)$ is $O(g(n))$ iff $\exists_{c,k}$ such that $f(n) \leq c \cdot g(n)$ for all $n > k$

Or simply, the worst-case growth rate of a function as the input gets very large. When I give it more data, how does it slow down?

Let $h(n)$ be the height as a function with respect to $n$, the number of nodes. However, we don't know how to compute this function since this can vary based on the structure of the tree, not just the number of nodes. 

In other words, 2 trees can have 4 nodes, but be fundamentally different in structure

Since we can't compute the exact height function, $h(n)$, we analyze the worst-case scenario: which is the tallest possible tree with $n$ nodes, or simply $h_{max}(n)$

But this is also a problem. I don't know how to come up with a way to get the maximum height of any tree with $n$ nodes. Its impossible.

To fix this, we have to take the inverse of this functino, which is simply the minimum height of any tree with $n$ nodes, or $h_{min}(n)$. And I know how to come up with this function!

We can let the lower bound of this function be the 
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE5NzQzMzEwMDEsLTExMTU0NDM4OSw5Mz
E2MjQ2MzUsMTUyMDIzMzMwLC0xODI5ODczNzUsMjAwNTgyMjkw
NCwtNTU3NzMzMzkyLDE1NTg0MzQ1MDUsLTU5MTg1MTkyOSwtNz
ExMjY0MjYyLDEzODc4MDM5NDEsMTI5NDQxNjc4MCwxMTA5OTc4
NjI4LC0xNjU4ODQxNDgyLDQwOTU3ODEzOCwtNDA5NjMyNTkxXX
0=
-->