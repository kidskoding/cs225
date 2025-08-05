
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

Then, we need to check if the root's key is greater than the given key, and if so, we call `_find` and return the root's left node and the key

Otherwise, we can just call `_find` and then return the root's right node and the key

This full code for internal find, `_find`, is shown below

```
template <class K, class V>
BST<K, V>::TreeNode*& BST<K, V>::_find(TreeNode*& root, const K& key) {
    if(root == nullptr) { return root; }
    if(root->key == key) { return key; }

    if(root->key > key) {
        return _find(root->left, key);
    }

    return _find(root->right, key);
}
```

However, there are some questions to ask, especially since this was a recursive approach.

1. What if the tree is really tall? Because in a list, we don't want to write things recursively because the nodes will expend a lot of memory on the call stack. 
	- The only valid solution would be to implement this iteratively, but I wouldn't want to do this because they work in a naturally recursive format. For now we can safely ignore this because there isn't much of a use case, but this is still a problem.

We will now implement an internal insert function called `_insert`. The process is simple: to insert a node into a Binary Search Tree (BST), we search for the position where the new node should go, and then assign a new `TreeNode` with the given key and value at that location.

This works because, when we search for the correct position in the BST, we eventually reach a `null` pointer, since the key does not already exist in the tree. The `_find` function returns a **reference to that pointer**, giving us access to the exact spot where the new node should be inserted. With this reference, we can directly assign a new `TreeNode` to that location, effectively inserting the node into the tree.

The code for internal insert, `_insert` is shown below

```
template <class K, class V>
void BST<K, V>::_insert(TreeNode*& root, const K& key, const V& value) {
	// Create a new `TreeNode` at the null pointer location returned by `_find`
    _find(key) = new TreeNode(key, value);
}
```

This code looks a little bit weird, but it makes sense

 1. Recall that `_find(root, key)` returns a **reference to a pointer** (`TreeNode*&`), specifically the pointer in the tree where the node with `key` should be located
 2. When the key doesn’t exist, that pointer is **null**
 3. Because `_find` returns a **reference to that pointer**, you can assign to it **directly**

This code can be done more clearly to understand what's going on

```
template <class K, class V>
void BST<K, V>::_insert(TreeNode*& root, const K& key, const V& value) {
    // grab the reference/location to the pointer where `key` should be inserted
    TreeNode*& loc = _find(root, key);

    // assign `loc` to point to a new `TreeNode` with the given `key` and `value`
    loc = new TreeNode(key, value);
}
```

There is a bug if you don't add the ampersand to the `TreeNode*` type when creating `loc`, since that then creates a copy pointer which changing it only changes the copy

Its a preference as to which method is better for writing `_insert`; the first one is slightly more clear as it expresses the entire insertion action in a single, direct statement without introducing intermediate variables or extra steps.

The final step is to implement `remove` for a BST. This seems simple since I just need to find the location of the `TreeNode` that I want to remove and then set its pointer to null.

However, this actually will only work if the node is a **leaf node**.  There are two other cases we have to consider when removing a node, which rely on the node having at least one child

1. **Removing a leaf node** - If the node is a leaf node (has no children)
2. **Removing a node with one child (left or right)** - If the node has exactly either one left or right child, you remove the node by connecting its parent directly to that child. This bypasses the node being removed, preserving the BST structure without losing any nodes.
3. **Removing a node with two children** - If the node has two children, meaning it has both a left and right child, we need to instead find a replacement node to take the removed node’s place in order to maintain the property of a BST. This is either:
	-   The **inorder predecessor** (IOP) - the largest node in the left subtree
	-   The **inorder successor** (IOS) - the smallest node in the right subtree
	- Swap the target node’s key and value with the replacement node’s, then recursively remove the replacement node, which then falls into the simpler cases of leaf or single child

Finding the IOP and IOS is a very effective approach when removing a node with both a left and right child because it always runs in $O(h)$ time, where $h$ is the height of a tree

This is because when a left or right node follows a single path down a tree, the worst case occurs when the node travels through the entire path of $h$




<!--stackedit_data:
eyJoaXN0b3J5IjpbMjEzNjI3ODg0OCwxNjI4NjUxMzIsMTExOT
U0MjA4NSwtOTA2NzM5MDQzLDMxNDUwODU3OCwtMTM5NTA2MDA1
OCwxODYwNzE0MTg2LDcyNjYwODY0NCwxNjk2NDk2NTg5LDIwNz
YxNTk3ODgsMTcyNDY2MTY2NCw4MzIwNTE0NjUsMjAzNDQ4MTUy
MCwtOTg3OTE0NzQ5LC0xODA1NTQ3NTM5LDE5MTAyNTMzNTUsLT
IwMDY4MzAwMTksMTQ1MDY4OTUwNSw3MjU4MDE3MjksLTI3NTE4
OTYwNF19
-->