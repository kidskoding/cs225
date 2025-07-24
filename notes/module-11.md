
# Module 11 - BST and BST Implementation

Recall that all trees have **structure**. Fundamentally, a tree gives us **positions** that when we put nodes in a tree, we put them in a position. Previously, the trees we discussed were in a position that had no meaning whatsoever. Is there a way for us to put nodes in a specific position that has meaning?

For this to take place, we need to discuss a different type of tree: the **Binary Search Tree**, or BST. The BST has a property, in which a node's left subtree contains nodes with keys less than the node's key and a node's right subtree contains nodes with keys greater than the node's key.

When it comes to equality, we typically don't define it for a BST. We assume that there will not be any duplicates (every node is unique in value) in a BST, and therefore we don't place it anywhere. It still can be extended in a BST definition, but it ends up with odd decisions and semantics, so its just better to assume that all nodes in a BST are **unique**.

Mathematically speaking, for tree $T$ to be a BST: 
- $T = \empty$
- $T = (r, T_L, T_R)$, where $\forall_x \in T_L$, $x < r$ and $\forall_x \in T_R$, $x > r$

$x$ is a key in $T_L$, where $x < r$ and a key in $T_R$, where $x > r$

This creates structure in the tree, where if I wanted to find a node like 21, I would start searching from the root node, and then check if 21 is greater than or less than the root node and then descend to the right or left subtree respectively and repeat the process until I find the node of 21. In this process, we rule out half one of the subtrees. 

This is the unified process of searching that we have in a BST, which  gives the tree a proper structure, giving each node's position a meaning.

Simply speaking, a BST is a binary tree that is organized in a way where all the nodes in its left subtree are smaller than it and all of the nodes in the right subtree are bigger than it.

Finding a node in a BST is $O(h)$, where $h$ is the height of the tree. This is because the worst case occurs when we have to traverse all the way to the root of a leaf, which takes $h$ steps. This means that $O(h) \equiv O(n)$ because the height $h$ can be as large as $n$ in the worst case.

Below is a good concrete implementation of a BST

```
// BST.h

#pragma once
#include <unordered_map>

template <class K, class V>
class BST {
public:
    using TreeIterator = typename std::unordered_map<K, V>::iterator;

    BST();
    void insert(const K key, const K value);
    void remove(const K& key);
    TreeIterator find(const K& key);
    TreeIterator begin();
    TreeIterator end();

private:
    struct TreeNode {
        TreeNode* left;
        TreeNode* right;
        K key;
        V value;
    };

    TreeNode* root;
};
```

This looks great, it shows the exact functionalities we need for our BST

- `find` - Will be used to find a node in a BST. Returns a custom implemented `TreeIterator` that behaves like the STL iterator of a template library. This is because we want to return the iterator's `.end()` behavior when not found.
- `insert` - Will be used to insert a node into a BST
- `remove` - Will be used to remove a node from a BST

Lets first start with the simplest implementation, `find`

## `find`

To implement find in a BST, the process is pretty straightforward

1. Visit the root node; if it's greater than the root node, descend into the right subtree and visit its node. otherwise, descend into the left subtree and visit its node.
2. Repeat step one for each node as you descend until you find the node and return it
3. Otherwise, return the iterator's `.end()` behavior if the node was not found in the BST

First we will begin with the internal find (`_find`). The external find function will just wrap the internal find with `root`, and then dealing with the case when the pointer is null and returning an iterator to the `end` rather than an iterator to that node.

```
template <class K, class V>
BST<K, V>::TreeNode*& BST<K, V>::_find(TreeNode*& root, const K& key) {

}
```

This internal `_find` is a lot like `find` from a `LinkedList`. It returns a pointer to a reference of a `TreeNode`. This returns the pointer that points to the node that has the key that exists somewhere in my tree data structure. Or if not, the last pointer I found while trying to find it. And then we take in the `root`, which is our recursion and the `key`

Since this is a recursive problem we first need to figure out our base case, which is just checking if our root's key is equal to the key we want to find. If it is, we should just return the root, since it is a pointer as a reference to the root node!

However, this code will crash if `root` is null, so we need to add another base case to check if `root` is null. 


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTExOTkzNTQ4NjQsLTU3MjEyODU3MCwxNz
Q0NzkyNzU0LDE5MTk1Mjc3MjgsLTExNTY1NjE4MzksMTkyNjgw
MzQ0LDcwMjkxMTkyMyw1NDAwMjkxMDMsNTMwMjk2ODYzLC00Nz
U3NjI1OTEsLTcyMjQwNTk0NV19
-->