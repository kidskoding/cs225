
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
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTU1NzczMzM5MiwxNTU4NDM0NTA1LC01OT
E4NTE5MjksLTcxMTI2NDI2MiwxMzg3ODAzOTQxLDEyOTQ0MTY3
ODAsMTEwOTk3ODYyOCwtMTY1ODg0MTQ4Miw0MDk1NzgxMzgsLT
QwOTYzMjU5MV19
-->