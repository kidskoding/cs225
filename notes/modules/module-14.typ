#import "../diagrams.typ": steps, tree

= Adelson-Velsky Landis (AVL) Trees

Adelson-Velsky Landis trees, or simply *AVL trees* are *self-balancing binary search trees* that automatically keep themselves balanced through rotations after insertions and deletions, ensuring efficient operations

This means that we have to consider 3 things:

- Rotations
- Maintaining Height
- Detecting Imbalance - check subtree height in $O(1)$ time and compute balance in $O(1)$ time

We can compute balance by having each subtree store its height, which means that I can retrieve it in constant time

*Recognize the patterns to figure out which rotation to use*

If insertion occurred on a subtree, $t$, where a *"right stick"* formed (two consecutive right children and no left children), meaning that its right subtree was heavier, we would need to do a *L* rotation about $t$ to restore the balance of the tree. Notice in @avl-right-stick how 2 becomes the new root once we rotate left about 1.

#figure(
  steps((1, none, (2, none, 3)), (2, 1, 3)),
  caption: [A right stick fixed by an L rotation about 1],
) <avl-right-stick>

$h = x$ prior to the left rotation and is now $h = x + 1$, where $x$ is the height of the right subtree

We leverage this by noting that the balance factor, $b$ of $t$ is $+2$ and the balance factor of `t->right` is 1, which is greater than 0 (`t->right > 0`)

If insertion occurred on a subtree, $t$, where a *"right elbow"* formed (right child has taller left subtree), we would need to do a *RL* rotation about $t$ to restore the balance of the tree (see @avl-right-elbow, where the R rotation about 3 first turns the elbow into a right stick).

#figure(
  steps((1, none, (3, 2, none)), (1, none, (2, none, 3)), (2, 1, 3)),
  caption: [A right elbow fixed by an RL rotation: an R rotation about 3, then an L rotation about 1],
) <avl-right-elbow>

We leverage this by noting that the balance factor, $b$ of `t->right` is -1, which is less than 0 (`t->right < 0`)

The opposites are true for a *"left stick"* and *"left elbow"*, where we would need *R* and *LR* rotations respectively. If you compare @avl-left-stick and @avl-left-elbow with the right side versions above, they're just mirror images

#figure(
  steps((3, (2, 1, none), none), (2, 1, 3)),
  caption: [A left stick fixed by an R rotation about 3],
) <avl-left-stick>

#figure(
  steps((3, (1, none, 2), none), (3, (2, 1, none), none), (2, 1, 3)),
  caption: [A left elbow fixed by an LR rotation: an L rotation about 1, then an R rotation about 3],
) <avl-left-elbow>

== Insertion into an AVL tree

With the knowledge in BST rotations, to insert a node into an AVL tree, we know we have to do the following steps

+ Insert at proper place
+ Check for imbalance
+ Rotate, if necessary
+ Update height

We already established that we need each `TreeNode` in an AVL tree to track its height. Therefore, we add a `height` member to each `TreeNode`

```cpp
struct TreeNode {
    K key;
    V value;

    // have each `TreeNode` store the height in order to self balance
    unsigned int height;

    TreeNode* left;
    TreeNode* right;

    // a new node is a leaf, so it has height 0 and no children
    TreeNode(const K& key, const V& value)
        : key(key), value(value), height(0), left(nullptr), right(nullptr) {}
};
```

Inserting a node into an AVL tree is very similar to a BST (since it is in fact a type of BST!), as shown below

```cpp
// AVL.hpp

/** Inserts a node as in a BST, without rebalancing yet
 * Runtime: O(h)
 */
template <typename K, typename V>
void AVL<K, V>::_insert(const K& key, const V& value, TreeNode*& curr) {
    // found the empty spot where the new node belongs
    if(curr == nullptr) {
        curr = new TreeNode(key, value);
        return;
    }

    // maintain BST property
    if(curr->key > key) {
        _insert(key, value, curr->left);
    } else if(curr->key < key) {
        _insert(key, value, curr->right);
    }

    // we still need to ensure the balance of the AVL tree here
}

/** Inserts a key-value pair into the AVL tree
 * Runtime: O(h)
 */
template <typename K, typename V>
void AVL<K, V>::insert(K key, V value) {
    _insert(key, value, root);
    node_map[key] = value;
}
```

The code above ensures the AVL tree maintains BST properties by descending into the left subtree if the key is smaller and descending into the right subtree if the key is greater

However, we are missing one crucial detail: ensuring that the AVL tree is *balanced*. To do this, we need to calculate the *balance factor* and then based on the balance factor, perform the appropriate rotation

The balancing function is outlined below

```cpp
// AVL.hpp

/** Rotates `curr`'s subtree if it is unbalanced (rotations not filled in yet)
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_ensureBalance(TreeNode*& curr) {
    // calculate the balance factor
    int balance = height(curr->right) - height(curr->left);

    // check if the node is currently not in balance
    if(balance == -2) { // heavy left ("left stick" or "left elbow" shaped subtree)
        int leftBalance = height(curr->left->right) - height(curr->left->left);
        if(leftBalance <= 0) {
            // perform right rotation
        } else {
            // perform left-right rotation
        }
    } else if(balance == 2) { // heavy right ("right stick" or "right elbow" shaped subtree)
        int rightBalance = height(curr->right->right) - height(curr->right->left);
        if(rightBalance >= 0) {
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

- If the balance is -2, we know that the shape of the left subtree is either a *"left stick"* or *"left elbow"*
  - We then need to compute the balance of the left subtree to figure out specifically which one it is
  - A left subtree balance of -1 means that its a *"left stick"*, so we need to do a *right rotation*
  - A left subtree balance of +1 means that its a *"left elbow"*, so we need to do a *left-right rotation*
- Similarly, if the balance is +2, we know that the shape of the right subtree is either a *"right stick"* or *"right elbow"*
  - We then need to compute the balance of the right subtree to figure out specifically which one it is
  - A right subtree balance of +1 means that its a *"right stick"*, so we need to do a *left rotation*
  - A right subtree balance of -1 means that its a *"right elbow"*, so we need to do a *right-left* rotation
  - After a `remove`, the child's balance can also be 0. That case is fixed with a single rotation too, which is why the code checks `rightBalance >= 0` (and `leftBalance <= 0` on the left side) instead of exactly $plus.minus 1$

We need a helper height function in order to avoid any crashes. While `curr->left->height` and `curr->right->height` do work, they may crash if `curr->left` and `curr->right` are null.

Therefore, a helper function to get the height of a node can help prevent any unnecessary crashes. It simply checks if the node is not null before calling its height property, and returns -1 for a null node, since the height of a null tree is -1. The code is shown below

```cpp
// AVL.hpp

/** Returns the height of a node, or -1 for a null node
 * Runtime: O(1)
 */
template <typename K, typename V>
int AVL<K, V>::height(TreeNode* node) {
    return node != nullptr ? node->height : -1;
}
```

We also need a helper function to update the height after performing necessary rotations

The updated node's height is 1 plus the max height of its left and right subtrees

Height represents the number of edges in the longest path from that node down to a leaf. When calculating this longest path, you need to consider that it will go through either the left subtree or the right subtree, depending on whichever is taller. This is performed by taking the maximum height between the two subtrees

However, to get the total path length from the current node, you must add one additional edge, because that accounts for descending into the taller subtree, which `_updateHeight` does below

```cpp
// AVL.hpp

/** Recomputes the height of `curr` from its children
 * Runtime: O(1)
 */
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

+ *Left Rotation*
  - The right child becomes the new root of the subtree
  - The new root's left subtree becomes the old root's right child
  - The old root becomes the left child of the new root of the subtree
  - Update the heights of the old root and then the new root, since only those two nodes moved
+ *Right Rotation*
  - The left child becomes the new root of the subtree
  - The new root's right subtree becomes the old root's left child
  - The old root becomes the right child of the new root of the subtree
  - Update the heights of the old root and then the new root, since only those two nodes moved
+ *Left-Right Rotation*
  - Perform a left rotation about the left child
  - Perform a right rotation about the root
+ *Right-Left Rotation*
  - Perform a right rotation about the right child
  - Perform a left rotation about the root

Coding these then becomes easy. Below are `_rotateLeft`, `_rotateRight`, `_rotateLeftRight`, and `_rotateRightLeft`, in that order

```cpp
// AVL.hpp

/** Rotates the subtree at `root` to the left
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_rotateLeft(TreeNode*& root) {
    // the right child becomes the new root
    TreeNode* newRoot = root->right;

    // move `newRoot`'s left subtree to old root's right subtree
    root->right = newRoot->left;

    // the old root becomes the left child of the new root
    newRoot->left = root;

    // the old root is now below the new root, so update its height first
    _updateHeight(root);
    _updateHeight(newRoot);

    // update pointer to point to the new root
    root = newRoot;
}
```

```cpp
// AVL.hpp

/** Rotates the subtree at `root` to the right
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_rotateRight(TreeNode*& root) {
    // the left child becomes the new root
    TreeNode* newRoot = root->left;

    // move `newRoot`'s right subtree to old root's left subtree
    root->left = newRoot->right;

    // the old root becomes the right child of the new root
    newRoot->right = root;

    // the old root is now below the new root, so update its height first
    _updateHeight(root);
    _updateHeight(newRoot);

    // update pointer to point to the new root
    root = newRoot;
}
```

```cpp
// AVL.hpp

/** Rotates left about the left child, then right about `root`
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_rotateLeftRight(TreeNode*& root) {
    // rotate left about the left child and then rotate right about the root
    _rotateLeft(root->left);
    _rotateRight(root);
}
```

```cpp
// AVL.hpp

/** Rotates right about the right child, then left about `root`
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_rotateRightLeft(TreeNode*& root) {
    // rotate right about the right child and then rotate left about the root
    _rotateRight(root->right);
    _rotateLeft(root);
}
```

This updates our balance function as follows

```cpp
// AVL.hpp

/** Rotates the subtree at `curr` if it is out of balance
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_ensureBalance(TreeNode*& curr) {
    // calculate the balance factor
    int balance = height(curr->right) - height(curr->left);

    // check if the node is currently not in balance
    if(balance == -2) {
        int leftBalance = height(curr->left->right) - height(curr->left->left);
        if(leftBalance <= 0) { // heavy left ("left stick" shaped subtree)
            _rotateRight(curr);
        } else { // "left elbow" shaped subtree
            _rotateLeftRight(curr);
        }
    } else if(balance == 2) {
        int rightBalance = height(curr->right->right) - height(curr->right->left);
        if(rightBalance >= 0) { // heavy right ("right stick" shaped subtree)
            _rotateLeft(curr);
        } else { // "right elbow" shaped subtree
            _rotateRightLeft(curr);
        }
    }

    // update the height of `curr`, which is the root of this subtree after any rotation
    _updateHeight(curr);
}
```

Finally, `_insert` calls `_ensureBalance` on every node along the path back up from the new node, so any imbalance is fixed right where it appears

```cpp
// AVL.hpp

/** Inserts a node and rebalances every node on the way back up
 * Runtime: O(h) = O(log n)
 */
template <typename K, typename V>
void AVL<K, V>::_insert(const K& key, const V& value, TreeNode*& curr) {
    // found the empty spot where the new node belongs
    if(curr == nullptr) {
        curr = new TreeNode(key, value);
        return;
    }

    // maintain BST property
    if(curr->key > key) {
        _insert(key, value, curr->left);
    } else if(curr->key < key) {
        _insert(key, value, curr->right);
    }

    // ensure the balance of the AVL tree (this also updates the height of `curr`)
    _ensureBalance(curr);
}
```

For example, inserting the keys 10, 20, 30, 25, 28 in that order triggers two rebalances. The first happens right after 30 goes in, when 10 becomes a right stick and gets an L rotation (see @avl-insert-right-stick-example). The second happens after 28, when 30 becomes a left elbow and needs an LR rotation, which you can follow step by step in @avl-insert-left-elbow-example.

#figure(
  grid(
    columns: 3,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: horizon + center,
    tree((10, none, (20, none, 30)), highlight: (10,)),
    $->$,
    tree((20, 10, 30), highlight: (20,)),
    [Insert 10, 20, 30], [], [L rotation about 10],
  ),
  caption: [Example: inserting 10, 20, 30 forms a right stick at 10 (balance +2), fixed by an L rotation],
) <avl-insert-right-stick-example>

#figure(
  grid(
    columns: 5,
    column-gutter: 1.5em,
    row-gutter: 0.8em,
    align: horizon + center,
    tree((20, 10, (30, (25, none, 28), none)), highlight: (30,)),
    $->$,
    tree((20, 10, (30, (28, 25, none), none)), highlight: (25,)),
    $->$,
    tree((20, 10, (28, 25, 30)), highlight: (28,)),
    [Insert 25, then 28], [], [L rotation about 25], [], [R rotation about 30],
  ),
  caption: [Example: inserting 25 and then 28 forms a left elbow at 30 (balance $-2$, left child balance $+1$), fixed by an LR rotation],
) <avl-insert-left-elbow-example>

I will not code the remaining functionalities, including `find` and `remove`. `find` is identical to a regular BST, so please see the BST implementation for it. `remove` starts out exactly like BST `remove`, but it is *not* identical: removing a node can unbalance every ancestor on the path back up to the root. Just like `_insert`, `_remove` must call `_ensureBalance` on each node as the recursion unwinds, and a single `remove` may need a rotation at several of those nodes (up to $O(log n)$ rotations), while an `insert` needs at most one.

== AVL Tree Analysis

`insert`, `remove`, and `find` also all run in $O(h)$. Recall that this is because in the worst case, we may need to traverse from the root down to a leaf node, visiting $h + 1$ nodes.

However, we will now argue that $h = O(log n)$, using the balance property to prove this

Recall from discrete math, the definition of big-O states that $f(n)$ is $O(g(n))$ iff $exists_(c, k)$ such that $f(n) <= c dot g(n)$ for all $n > k$

Or simply, the worst-case growth rate of a function as the input gets very large. When I give it more data, how does it slow down?

Let $h(n)$ be the height of an AVL tree as a function of $n$, the number of nodes. However, we can’t directly compute this function, since tree height depends on not only the number of nodes, but also on the structure of the tree.

In other words, 2 AVL trees can have 4 nodes, but be fundamentally different in structure

Since we can't compute the exact height function, $h(n)$, we analyze the worst-case scenario: which is the tallest possible tree with $n$ nodes, or simply $h_"max" (n)$

But directly computing $h_"max" (n)$ is also difficult. There are too many possible tree shapes to check them all. Instead, we approach the problem indirectly by taking the inverse and finding the *minimum number of nodes* required to build an AVL tree of height $h$

This makes sense because when I find the lower bound of the inverse, $h_"min" (n)$, I essentially get the upper bound on $h_"max" (n)$

The number of nodes in the tree, $f^(-1)(h)$ will always be *greater than* $c times g^(-1)(h)$ for all values where $n > k$

This is because if one function grows slower than another, its inverse must grow faster, so to reach the same output, the slower-growing function requires a larger input, making its inverse larger (up to a constant factor) for sufficiently large values

To find the lower bound on $n$ given $h$, we can begin by defining a function given $h$, which describes the *smallest number of nodes in an AVL tree* given height $h$

$"NODES"(h)$ is the minimum number of nodes in an AVL tree of height $h$.

- When $h = -1$, $"NODES"(h) = 0$ because the tree is *empty*
- When $h = 0$, only one tree exists because only the root node exists in such tree, so $"NODES"(h) = 1$
- When $h = 1$, there are three possible trees: a tree with only a *left child*, a tree with only a *right child*, and a tree with *both* a *left and right* child. $"NODES"(h) = 2$ since the minimum number of nodes required for height 1 is $2$
- When we get to $h = 2$, however, I get a lot of possible trees and not all of them are balanced.
  - However, there is one possible balanced tree that can be formed with a minimum of four nodes, where the *root's left child also contains a right child*
  - This forms a minimum of $4$ nodes, where $"NODES"(h) = 4$, as in @avl-min-tree-height-2 (the root's left child 1 has the right child 2)

#figure(
  tree((3, (1, none, 2), 4)),
  caption: [A minimum-size AVL tree of height 2],
) <avl-min-tree-height-2>

Assuming that $N(h)$ is an alias for $"NODES"(h)$, we build a recurrence relation, where

$ N(h) = 1 + N(h - 1) + N(h - 2) $

If we build the first few minimum-size AVL trees with this recurrence, we get @avl-min-trees. Notice how the tree for $N(3)$ is just a root with the $N(2)$ tree on its left and the $N(1)$ tree on its right.

#figure(
  grid(
    columns: 4,
    column-gutter: 2em,
    row-gutter: 0.8em,
    align: bottom + center,
    tree((1,)),
    tree((2, 1, none)),
    tree((3, (2, 1, none), 4)),
    tree((5, (3, (2, 1, none), 4), (7, 6, none))),
    [$N(0) = 1$], [$N(1) = 2$], [$N(2) = 4$], [$N(3) = 7$],
  ),
  caption: [Minimum-size AVL trees of heights 0 to 3: each is a root, a minimum tree of height $h - 1$ on the left, and a minimum tree of height $h - 2$ on the right],
) <avl-min-trees>

We can first argue that $N(h) = 1 + N(h - 1) + N(h - 2)$, which means that $N(h) > 2N(h - 2)$. This is important so that we establish a lower bound on the minimum required number of nodes for height $h$

We can argue that the minimum number of nodes $N(h)$ in an AVL tree of height $h$ is equal to the sum of one root node plus the minimum nodes of its two subtrees: $N(h) = 1 + N(h - 1) + N(h - 2)$.

Since $N(h - 1) > N(h - 2)$, this implies $N(h) > 1 + 2N(h - 2)$ because $N(h - 1)$ is strictly greater than $N(h - 2)$

For larger $h$, the constant 1 becomes insignificant, so we simplify this to $N(h) > 2N(h - 2)$, showing that $N(h)$ grows exponentially as the height increases

With this, we can prove a closed form of $2N(h - 2)$

Prove that an AVL tree of height $h$ has at least $2^(h/2)$ nodes.

Consider an AVL tree and let $h$ denote its height. Start with $h = 1$

$ N(1) = 2^1 = 2 $

$ 2^(1/2) = sqrt(2) $

and $2 >= sqrt(2)$

This means that an AVL tree with height $1$ has at least $sqrt(2)$ nodes

Suppose $h = 2$

$
  N(2) & = 1 + N(2 - 2) + N(2 - 1) \
       & = 1 + 1 + 2 \
       & = 4
$

$ 2^(2/2) = 2^1 = 2 $

and $4 >= 2$, which means that an AVL tree with height $2$ has at least $2$ nodes

By inductive hypothesis

$forall_(j < h)$, $N(j) >= 2^(j/2)$, where we will prove via inductive step that

$ N(h) = N(h - 1) + N(h - 2) + 1 > 2N(h - 2) $

$ 2N(h - 2) >= 2 times 2^((h - 2)/2) = 2^(h/2) $

An AVL tree of height $h$ has at least $2^(h/2)$ nodes.

via induction, we have shown that $n >= N(h) >= 2^(h/2)$, where inverting this results in

$ h <= 2 log n $

meaning that

$ h equiv O(log n) $

== Summarizing AVL and BBST

*Red-Black Trees*

- BBST's where max height is equal to $2 dot log n$
- Constant number of rotations on `insert`, `remove`, and `find`, $O(1)$

*AVL Trees*

- *Max Height*: $1.44 dot log n$
- *Rotations*: $O(h)$

Red-Black trees outperform AVL trees in rotations. They are also laid out well in memory that improves cache performance.

Red-Black trees are much more complicated to understand how they work under the hood

Previously, when we were constructing BST's, we were using `std::unordered_map` to track our nodes. This was so that we had access to a fast iterator. But there is actually something even more interesting about this.

C++ STL maps in fact provide us with a balanced BST that is in fact a red-black tree. When we use `operator[]` on a map, what we are essentially doing is searching for the key in a tree and

- *If the key exists*, it returns a reference to the corresponding value.
- *If the key doesn't exist*, it inserts the key with a default-constructed value and then returns a reference to that value.

But from a big-O standpoint, all operations are $O(log n)$, considering the trees are *balanced*, which is a huge improvement from $O(n)$ of a regular BST

This is great for specific applications when looking for close matches, such as range queries, nearest-neighbor lookups, or finding the next largest or smallest key, all of which benefit from the in-order structure and efficient traversal of balanced binary search trees like red-black trees

== Runtime Analysis for all Data Structures Covered

#table(
  columns: 8,
  table.header(
    [], [Unsorted Array], [Sorted Array], [Unsorted List], [Sorted List], [Binary Tree], [BST], [AVL],
  ),
  [`find`], [$O(n)$], [$O(log n)$], [$O(n)$], [$O(n)$], [$O(n)$], [$O(h)$], [$O(log n)$],
  [`insert`], [$O(1)$], [$O(n)$], [$O(1)$], [$O(n)$], [$O(n)$], [$O(h)$], [$O(log n)$],
  [`remove`], [$O(n)$], [$O(n)$], [$O(n)$], [$O(n)$], [$O(n)$], [$O(h)$], [$O(log n)$],
  [`traverse`], [$O(n)$], [$O(n)$], [$O(n)$], [$O(n)$], [$O(n)$], [$O(n)$], [$O(n)$],
)
