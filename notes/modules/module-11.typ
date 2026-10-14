#import "../diagrams.typ": tree

= BST and BST Implementation

Recall that all trees have *structure*. Fundamentally, a tree gives us *positions* that when we put nodes in a tree, we put them in a position. Previously, the trees we discussed were in a position that had no meaning whatsoever. Is there a way for us to put nodes in a specific position that has meaning?

For this to take place, we need to discuss a different type of tree: the *Binary Search Tree*, or BST. The BST has a property, in which a node's left subtree contains nodes with keys less than the node's key and a node's right subtree contains nodes with keys greater than the node's key.

When it comes to equality, we typically don't define it for a BST. We assume that there will not be any duplicates (every node is unique in value) in a BST, and therefore we don't place it anywhere. It still can be extended in a BST definition, but it ends up with odd decisions and semantics, so it's just better to assume that all nodes in a BST are *unique*.

Mathematically speaking, for tree $T$ to be a BST:

- $T = emptyset$
- $T = (r, T_L, T_R)$, where $forall_x in T_L$, $x < r$ and $forall_x in T_R$, $x > r$

$x$ is a key in $T_L$, where $x < r$ and a key in $T_R$, where $x > r$

In @bst-property-example, the tree on the left is a valid BST, but the one on the right breaks this property because of the highlighted 12.

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: bottom + center,
    tree((10, (5, 2, 7), 15)),
    tree((10, (5, 2, 12), 15), highlight: (12,)),
    [A BST], [Not a BST],
  ),
  caption: [Example: on the right, 12 is a valid right child of 5, but it lies in the left subtree of 10 while $12 > 10$. The property must hold for the whole subtree, not just the parent],
) <bst-property-example>

This creates structure in the tree, where if I wanted to find a node like 21, I would start searching from the root node, and then check if 21 is greater than or less than the root node and then descend to the right or left subtree respectively and repeat the process until I find the node of 21. In this process, we rule out half one of the subtrees. Notice in @bst-search-path how the search for 21 only touches the highlighted path 15, 25, 21.

#figure(
  tree((15, (8, 4, 12), (25, 21, 30)), highlight: (15, 25, 21)),
  caption: [Example: finding 21 visits 15, 25, 21 ($21 > 15$, go right; $21 < 25$, go left). The left subtree of 15 is never touched],
) <bst-search-path>

This is the unified process of searching that we have in a BST, which gives the tree a proper structure, giving each node's position a meaning.

Simply speaking, a BST is a binary tree that is organized in a way where all the nodes in its left subtree are smaller than it and all of the nodes in the right subtree are bigger than it.

Finding a node in a BST is $O(h)$, where $h$ is the height of the tree. This is because the worst case occurs when we have to traverse all the way to the root of a leaf, which takes $h$ steps. This means that $O(h) equiv O(n)$ because the height $h$ can be as large as $n$ in the worst case.

Below is a good concrete implementation of a BST

```cpp
// BST.h

#pragma once
#include <unordered_map>

template <class K, class V>
class BST {
public:
    using TreeIterator = typename std::unordered_map<K, V>::iterator;

    BST() : root(nullptr) { }

    /** Inserts a key-value pair into the BST
     * Runtime: O(h)
     */
    void insert(const K key, const V value);

    /** Removes the node with the given key from the BST
     * Runtime: O(h)
     */
    void remove(const K& key);

    /** Returns an iterator to the pair with `key` (looked up in `node_map`)
     * Runtime: expected O(1)
     */
    TreeIterator find(const K& key);

    /** Returns an iterator to the first key-value pair
     * Runtime: O(1)
     */
    TreeIterator begin();

    /** Returns an iterator one past the last key-value pair
     * Runtime: O(1)
     */
    TreeIterator end();

private:
    struct TreeNode {
        TreeNode* left;
        TreeNode* right;
        K key;
        V value;

        TreeNode(const K& key, const V& value) : left(nullptr), right(nullptr), key(key), value(value) { }
    };

    TreeNode* root;

    // a map that lets us use iterators for fast access without needing to traverse the tree
    std::unordered_map<K, V> node_map;

    // internal helpers

    /** Returns the pointer to `key`'s node, or the null spot where it goes
     * Runtime: O(h)
     */
    TreeNode*& _find(TreeNode*& root, const K& key);

    /** Inserts a new node at the null pointer `_find` stops on
     * Runtime: O(h)
     */
    void _insert(TreeNode*& root, const K& key, const V& value);

    /** Returns the pointer to the in-order predecessor of `root`
     * Runtime: O(h)
     */
    TreeNode*& _iop(TreeNode*& root);

    /** Swaps the key and value stored in two nodes
     * Runtime: O(1)
     */
    void _swap(TreeNode* a, TreeNode* b);

    /** Removes the node with `key` from the subtree rooted at `node`
     * Runtime: O(h)
     */
    void _remove(TreeNode*& node, const K& key);
};
```

This looks great, it shows the exact functionalities we need for our BST

Notice how we added an `std::unordered_map`, `node_map`. This helps us use the unordered map's iterator for fast access of our tree nodes, without having to constantly traverse the tree. It's a fast access cache alongside our BST

- `find` - Will be used to find a node in a BST. Returns a custom implemented `TreeIterator` that behaves like the STL iterator of a template library. This is because we want to return the iterator's `.end()` behavior when not found.
- `insert` - Will be used to insert a node into a BST
- `remove` - Will be used to remove a node from a BST

Let's first start with the simplest implementation, `find`

== `find`

To implement find in a BST, the process is pretty straightforward

+ Visit the root node; if it's greater than the root node, descend into the right subtree and visit its node. otherwise, descend into the left subtree and visit its node.
+ Repeat step one for each node as you descend until you find the node and return it
+ Otherwise, return the iterator's `.end()` behavior if the node was not found in the BST

First we will begin with the internal find (`_find`). The external find function will just wrap the internal find with `root`, and then dealing with the case when the pointer is null and returning an iterator to the `end` rather than an iterator to that node. The signature of `_find` is shown below.

```cpp
/** Returns the pointer to `key`'s node, or the null spot where it goes
 * Runtime: O(h)
 */
template <class K, class V>
typename BST<K, V>::TreeNode*& BST<K, V>::_find(TreeNode*& root, const K& key) {

}
```

This internal `_find` is a lot like `find` from a `LinkedList`. It returns a reference to a pointer to a `TreeNode`. This returns the pointer that points to the node that has the key that exists somewhere in my tree data structure. Or if not, the last pointer I found while trying to find it. And then we take in the `root`, which is our recursion and the `key`

Since this is a recursive problem we first need to figure out our base case, which is just checking if our root's key is equal to the key we want to find. If it is, we should just return the root, since it is a pointer as a reference to the root node!

However, this code will crash if `root` is null, so we need to add another base case to check if `root` is null.

Then, we need to check if the root's key is greater than the given key, and if so, we call `_find` and return the root's left node and the key

Otherwise, we can just call `_find` and then return the root's right node and the key

This full code for internal find, `_find`, is shown below

```cpp
// BST.hpp

/** Returns the pointer to `key`'s node, or the null spot where it goes
 * Runtime: O(h)
 */
template <typename K, typename V>
typename BST<K, V>::TreeNode*& BST<K, V>::_find(TreeNode*& root, const K& key) {
    // if the root's pointer is null, return the root or
    // if the root's key equals the given key, return the root
    if(root == nullptr || root->key == key) { return root; }

    // if the root's key is greater than the given key, call find on the left subtree
    if(root->key > key) {
        return _find(root->left, key);
    }

    // if the root's key is less than the given key, call find on the right subtree
    return _find(root->right, key);
}
```

To implement the external find, `find`, we can just simply return `node_map.find(key)` as an iterator, since `node_map` always stores the same key-value pairs as the BST and supports fast lookup:

```cpp
// BST.hpp

/** Returns an iterator to the pair with `key` (looked up in `node_map`)
 * Runtime: expected O(1)
 */
template <typename K, typename V>
typename BST<K, V>::TreeIterator BST<K, V>::find(const K& key) {
    // use `node_map` to quickly find the value without traversing the tree
    return node_map.find(key);
}
```

However, there are some questions to ask, especially since this was a recursive approach.

+ What if the tree is really tall? Because in a list, we don't want to write things recursively because the nodes will expend a lot of memory on the call stack.
  - The only valid solution would be to implement this iteratively, but I wouldn't want to do this because they work in a naturally recursive format. For now we can safely ignore this because there isn't much of a use case, but this is still a problem.

== `insert`

We will now implement an internal insert function called `_insert`. The process is simple: to insert a node into a Binary Search Tree (BST), we search for the position where the new node should go, and then assign a new `TreeNode` with the given key and value at that location.

This works because, when we search for the correct position in the BST, we eventually reach a `null` pointer, since the key does not already exist in the tree. The `_find` function returns a *reference to that pointer*, giving us access to the exact spot where the new node should be inserted. With this reference, we can directly assign a new `TreeNode` to that location, effectively inserting the node into the tree. For example, inserting 23 in @bst-insert-example follows the same path as a search (15, 25, 21), and 23 lands as the right child of 21.

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: horizon + center,
    tree((15, (8, 4, 12), (25, 21, 30)), highlight: (15, 25, 21)),
    $->$,
    tree((15, (8, 4, 12), (25, (21, none, 23), 30)), highlight: (23,)),
    [Search visits 15, 25, 21], [], [23 becomes the right child of 21],
  ),
  caption: [Example: inserting 23. `_find` stops at the null `right` pointer of 21, and the new node is assigned there],
) <bst-insert-example>

The code for internal insert, `_insert` is shown below

```cpp
// BST.hpp

/** Inserts a new node at the null pointer `_find` stops on
 * Runtime: O(h)
 */
template <class K, class V>
void BST<K, V>::_insert(TreeNode*& root, const K& key, const V& value) {
    // Create a new `TreeNode` at the null pointer location returned by `_find`
    _find(root, key) = new TreeNode(key, value);
}
```

This code looks a little bit weird, but it makes sense

+ Recall that `_find(root, key)` returns a *reference to a pointer* (`TreeNode*&`), specifically the pointer in the tree where the node with `key` should be located
+ When the key doesn't exist, that pointer is *null*
+ Because `_find` returns a *reference to that pointer*, you can assign to it *directly*

This code can be done more clearly to understand what's going on, by storing the result of `_find` in an explicit `loc` reference

```cpp
// BST.hpp

/** Inserts a new node at the null pointer `_find` stops on
 * Runtime: O(h)
 */
template <class K, class V>
void BST<K, V>::_insert(TreeNode*& root, const K& key, const V& value) {
    // grab the reference/location to the pointer where `key` should be inserted
    TreeNode*& loc = _find(root, key);

    // assign `loc` to point to a new `TreeNode` with the given `key` and `value`
    loc = new TreeNode(key, value);
}
```

There is a bug if you don't add the ampersand to the `TreeNode*` type when creating `loc`, since that then creates a copy pointer which changing it only changes the copy

It's a preference as to which method is better for writing `_insert`; the first one is slightly more clear as it expresses the entire insertion action in a single, direct statement without introducing intermediate variables or extra steps.

To then code the external `insert`, we just have to simply call the internal insert, `_insert` and then add the key to our `node_map`, which is an `std::unordered_map` that contains our `TreeNode`s

```cpp
// BST.hpp

/** Inserts a key-value pair into the BST
 * Runtime: O(h)
 */
template <typename K, typename V>
void BST<K, V>::insert(const K key, const V value) {
    _insert(root, key, value);

    // also insert the key-value pair into the hashmap for fast lookup and iterator support
    node_map[key] = value;
}
```

== `remove`

The final step is to implement `remove` for a BST. This seems simple since I just need to find the location of the `TreeNode` that I want to remove and then set its pointer to null.

However, this actually will only work if the node is a *leaf node*. There are two other cases we have to consider when removing a node, which rely on the node having at least one child

+ *Removing a leaf node* - If the node is a leaf node (has no children), its parent's pointer just becomes null (see @bst-remove-leaf)
+ *Removing a node with one child (left or right)* - If the node has exactly either one left or right child, you remove the node by connecting its parent directly to that child. This bypasses the node being removed, preserving the BST structure without losing any nodes. In @bst-remove-one-child, for example, removing 8 lets 15 point straight at 4.
+ *Removing a node with two children* - If the node has two children, meaning it has both a left and right child, we need to instead find a replacement node to take the removed node's place in order to maintain the property of a BST. This is either:
  - The *inorder predecessor* (IOP) - the largest node in the left subtree
  - The *inorder successor* (IOS) - the smallest node in the right subtree
  - Swap the target node's key and value with the replacement node's, then recursively remove the replacement node, which then falls into the simpler cases of leaf or single child. You can see this in @bst-remove-two-children, where the IOP of 15 is 12 (highlighted), so the two swap and 15 is then removed with the one child case

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: horizon + center,
    tree((15, (8, 4, 12), (25, 21, 30)), highlight: (4,)),
    $->$,
    tree((15, (8, none, 12), (25, 21, 30))),
  ),
  caption: [Example: removing the leaf 4. Its parent's `left` pointer simply becomes null],
) <bst-remove-leaf>

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: horizon + center,
    tree((15, (8, (4, 2, 6), none), (25, 21, 30)), highlight: (8,)),
    $->$,
    tree((15, (4, 2, 6), (25, 21, 30)), highlight: (4,)),
  ),
  caption: [Example: removing 8, which has only a left child. 15 now points directly at 4, and the whole subtree under 4 moves up with it],
) <bst-remove-one-child>

#figure(
  grid(
    columns: 5,
    column-gutter: 1.5em,
    row-gutter: 0.8em,
    align: horizon + center,
    tree((15, (8, 4, (12, 10, none)), 25), highlight: (15, 12)),
    $->$,
    tree((12, (8, 4, (15, 10, none)), 25), highlight: (15,)),
    $->$,
    tree((12, (8, 4, 10), 25)),
    [Find the IOP of 15], [], [Swap 15 and 12], [], [Remove 15 (one child)],
  ),
  caption: [Example: removing 15, which has two children. Its IOP is 12, the rightmost node of the left subtree (8, then right to 12). After the swap, 15 has only a left child, so it is removed with the one child case],
) <bst-remove-two-children>

Finding either IOP and IOS (it doesn't matter which one) is a very effective approach when removing a node with both a left and right child because it always runs in $O(h)$ time, where $h$ is the height of a tree

This is because when a left or right node follows a single path down a tree, the worst case occurs when the node travels through the entire path of $h$

First, we need a helper function that helps find either the IOP or IOS (will do IOP in this example). Recall that the IOP finds the largest node in the left subtree.

Therefore, to implement this, we need to find the rightmost value in the left subtree, since this will always be the largest value according to the BST property. To find the largest value, we just need to iterate through each node's right child until a node's right child no longer exists (null pointer). The code for finding the IOP is reflected below

```cpp
// BST.hpp

/** Returns the pointer to the in-order predecessor of `root`
 * Runtime: O(h)
 */
template <typename K, typename V>
typename BST<K, V>::TreeNode*& BST<K, V>::_iop(TreeNode*& root) {
    // grab a pointer to the left subtree pointer of the root
    // (a pointer to the pointer, so moving `curr` never overwrites a link in the tree)
    TreeNode** curr = &root->left;

    // iterate through each right child of the left subtree to find the rightmost node
    // return the rightmost node (since that always contains the greatest value)
    while((*curr)->right != nullptr) {
        curr = &(*curr)->right;
    }
    return *curr;
}
```

The next thing we need to code is a helper swap function that swaps the internal data between two nodes. This is simple, it's just swapping the key and value of two nodes. We can use C++ STL swap function to achieve this. The code is shown below

```cpp
// BST.hpp

/** Swaps the key and value stored in two nodes
 * Runtime: O(1)
 */
template <typename K, typename V>
void BST<K, V>::_swap(TreeNode* a, TreeNode* b) {
    // swap the internal data of nodes `a` and `b`
    std::swap(a->key, b->key);
    std::swap(a->value, b->value);
}
```

Finally, we can top it off by coding the functionality of `remove`. We first need a helper to handle `remove`, `_remove`, for all kinds of nodes, and then we can call the external remove with `root`.

Recall that `_remove` involves handling the cases that vary based on the number of children (leaf node - no children, either a left or right child, both a left or right child). The code for `_remove` is shown below

```cpp
// BST.hpp

/** Removes the node with `key` from the subtree rooted at `node`
 * Runtime: O(h)
 */
template <typename K, typename V>
void BST<K, V>::_remove(TreeNode*& node, const K& key) {
    if(node == nullptr) { return; }

    if(key < node->key) {
        // descend down the left subtree because left subtree contains the smaller values
        _remove(node->left, key);
    } else if(key > node->key) {
        // descend down the right subtree because right subtree contains the larger values
        _remove(node->right, key);
    } else {
        // case 1: the leaf node case - free the node and set it to null
        if(node->left == nullptr && node->right == nullptr) {
            delete node;
            node = nullptr;
        }

        // case 2: the one child node case (either left or right child)
        else if(node->left == nullptr) {
            // remove the node by connecting its parent directly to the node’s only child (the right child)
            TreeNode* tmp = node;
            node = node->right;
            delete tmp;
        }
        else if(node->right == nullptr) {
            // remove the node by connecting its parent directly to the node’s only child (the left child)
            TreeNode* tmp = node;
            node = node->left;
            delete tmp;
        }

        // case 3: the two child node case (both left and right child)
        // swap the removed node with the iop and recursively call the function on the left subtree
        else {
            K iop_key = node->key;
            TreeNode* iop = _iop(node);
            _swap(iop, node);

            // recursively call on the left subtree because the iop (the node to remove) is located there
            _remove(node->left, iop_key);
        }
    }
}
```

A lot of things happen in this code, but most of it has already been previously explained. A couple things to clarify however,

+ If the key we need to remove is less than the node's key, it makes sense to descend down the left subtree, since that contains keys less than the key we need to remove
+ If the key we need to remove is greater than the node's key, it makes sense to descend down the right subtree, since that contains keys greater than the key we need to remove
+ We have to check which child is null for the one child case.
  - When we get to the else if statement, we know that at least one child has to point to some node since we already checked if both were null, and obviously wasn't the case
  - If only the right child is present (the left child is null), then we can simply remove the node and connect its parent directly to this right child. The same thing works with the left child: if only the left child is present, remove the node and connect its parent directly to this left child.
+ For the two child case, once we found the iop and swapped it with the current node, we have to recursively call `_remove` on the left subtree, since that is where the IOP will always be located. That is because the IOP is the greatest node in the left subtree, but smaller than its root (meaning it is the rightmost node of the left subtree)

This makes coding the exposed (external) version of `remove` simple. We just call `_remove` and pass in the root

```cpp
// BST.hpp

/** Removes the node with the given key from the BST
 * Runtime: O(h)
 */
template <typename K, typename V>
void BST<K, V>::remove(const K& key) {
    _remove(root, key);

    // remove the key from the map
    node_map.erase(key);
}
```

`begin()` and `end()` work by simply returning the begin and end iterators of `node_map`, our unordered map

```cpp
// BST.hpp

/** Returns an iterator to the first key-value pair
 * Runtime: O(1)
 */
template <typename K, typename V>
typename BST<K, V>::TreeIterator BST<K, V>::begin() {
    return node_map.begin();
}

/** Returns an iterator one past the last key-value pair
 * Runtime: O(1)
 */
template <typename K, typename V>
typename BST<K, V>::TreeIterator BST<K, V>::end() {
    return node_map.end();
}
```

== BST-Analysis

The table below summarizes the runtime for all our important BST algorithms

#table(
  columns: 2,
  table.header([*Operation*], [*BST Worst Case*]),
  [`find`], [$O(h) equiv O(n)$],
  [`insert`], [$O(h) equiv O(n)$],
  [`remove`], [$O(h) equiv O(n)$],
  [`traverse`], [$O(n)$],
)

For the operations `find`, `insert`, and `remove` on a BST, the worst-case time complexity depends on the height $h$ of the tree. These operations require traversing from the root down to a specific node, which involves up to $h$ recursive or iterative steps. Therefore, their worst-case time complexity is $O(h)$.

If the height $h$ of a Binary Search Tree (BST) can be as large as the number of nodes $n$ in the worst case, then any operation that takes $O(h)$ time can take up to $O(n)$ time. The worst-case scenario holds when $O(h) equiv O(n)$

The height $h$ of a BST is the length of the longest path from the root to a leaf, measured in edges

+ The worst case scenario occurs when the BST weakens into a `LinkedList`, where each node has only one child
+ The height of this worst case scenario BST, $h$, then becomes $n - 1$, where $h = n - 1$, since the longest path must visit all nodes except the root

$h = n - 1$, so that means $O(h) = O(n - 1) = O(n)$. Since constants are insignificant in measuring an algorithm's runtime, meaning that $O(h) equiv O(n)$
